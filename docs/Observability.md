# Observability

Every metric the app collects, exactly what it contains, and how to
validate it during beta. Rule: **no personal information leaves the
device** — events carry counts, durations, route templates and error
shapes, never names, emails, list contents, or concrete record IDs.

Demo mode sends nothing anywhere (console only). Connected builds
insert into the `analytics` table (RLS: insert-own), rows deleted with
the account.

## Event dictionary

| Event | Properties | Fired when |
|---|---|---|
| `startup` | `init_ms`, `first_frame_ms`, `mode` (demo/connected), `platform` | Every launch ([main.dart](../lib/main.dart)) — the DAU/WAU anchor event |
| `session_end` | `seconds` (foreground stretch) | App backgrounded/hidden; force-kill loses the final event (biases short, never long) |
| `screen_view` | `route` (template, e.g. `/products/:id` — never the concrete URI) | Every navigation ([app_router.dart](../lib/core/router/app_router.dart)) |
| `auth_success` | `demo` | The real signed-out→signed-in auth-state transition (central listener in app_router) — recording at the sign-in button would count cancelled OAuth launches and fire before a session exists. Per-provider breakdown deliberately dropped with it. |
| `list_created` | `has_budget` | Shopping list created |
| `optimize_run` | `items`, `options`, `multi_store_recommended`, `duration_ms` (fetches + solve) | Basket optimization completes |
| `trip_started` | `stops` | Optimized route handed to the navigation app — the optimizer-acceptance event |
| `map_ready` | `ms` (screen construction → interactive map) | Map screen first renders |
| `product_search` | `results` — never the query text; zero results = missing-catalog signal | Debounced catalog search with ≥3 chars |
| `coupon_clipped` | `clipped` | Coupon clipped/unclipped |
| `meal_plan_generated` | `meals`, `had_budget` | AI meal plan saved |
| `http_request` | `host`, `path` (digit runs collapsed), `status`, `ms` — never query strings or bodies | Each external (non-Supabase) HTTP request |
| `pending_ops_drained` | `applied`, `dropped` | Offline check-off queue flushes (reconnect or startup) |
| `receipt_prices_recorded` | `items`, `recorded` | Receipt saved; how many lines became price observations |
| `price_reported` | `has_store` | Community price report submitted |
| `barcode_external_lookup` | `found` | Scanned barcode missed the catalog and was sent to Open Food Facts (measures catalog coverage) |
| `onboarding_complete` | — | First-run walkthrough finished |
| `feedback_opened` | — | Feedback email drafted (intent; the mail client decides sending) |
| `data_exported` | — | Data export copied to clipboard |
| `account_deleted` | `demo` | Deletion **requested** (fires pre-call by necessity: post-deletion there is no session to log with; a failed attempt still counts) |
| `app_error` | `error` (scrubbed + truncated; PostgREST errors send code+message only), `type` (runtime type), `fatal` | Any uncaught or recorded error |

**Funnel** (each step / previous = conversion): `startup` →
`onboarding_complete` → `auth_success` → `list_created` →
`optimize_run` → `trip_started`. Optimizer acceptance rate =
`trip_started / optimize_run`. Offline edits are deliberately NOT
evented at enqueue time — the device is offline, the insert would be
lost; `pending_ops_drained` reconciles on reconnect instead.

```sql
-- DAU / WAU from the anchor event:
select date_trunc('day', created_at) d, count(distinct user_id)
from analytics where event = 'startup' group by 1 order by 1;
```

## PII policy per pipeline

- **`app_error` → analytics table**: `Telemetry.scrub()` strips
  email-shaped tokens, URL query strings, and 6+-digit runs, then
  truncates to 300 chars. Pinned by
  [telemetry_scrub_test.dart](../test/core/telemetry_scrub_test.dart).
- **Feedback email ring buffer**: milder `redact()` (truncate only),
  because the user sees the exact text in the draft email and decides
  whether to send it.
- **Release console logs**: truncated form only (`kDebugMode` gate).

## Beta success metrics

- **Activation**: `onboarding_complete` / first `screen_view`
- **Core value**: `optimize_run` per active user per week
- **Live data**: `receipt_prices_recorded.recorded` and
  `price_reported` totals — is real price data actually accumulating?
- **Catalog coverage**: `barcode_external_lookup` where `found=false`
  (products users want that neither catalog nor OFF know)
- **Reliability**: `app_error` rate, `pending_ops_drained.dropped`
  (should be ~0), `startup.first_frame_ms` and `optimize_run.duration_ms`
  distributions

## Validating events (connected beta)

```sql
-- Are events arriving, and in sane proportions?
select event, count(*) from analytics
where created_at > now() - interval '7 days'
group by event order by 2 desc;

-- Crash triage: newest errors, grouped by shape.
select properties->>'type' as type, properties->>'error' as error,
       count(*), max(created_at)
from analytics where event = 'app_error'
group by 1, 2 order by count(*) desc limit 20;
```

Review cadence during beta: errors weekly (or after any tester
report), event proportions before each rc tag.

## Crash reporting decision

In-house (Telemetry → analytics table) for the closed beta:
one integration point, zero third-party data sharing to disclose,
queryable with the SQL above. `AppConfig.sentryDsn` is already plumbed
for a hosted service (Sentry/Crashlytics) — wire it in
`Telemetry.recordError` when beta volume outgrows SQL triage. That is
a deliberate deferral, not an accident.

## What is intentionally NOT collected

Location coordinates, search queries, list/pantry/receipt contents,
product IDs viewed (only the route *template*), voice transcripts,
concrete URLs with parameters, memory/battery profiles (measured
locally with DevTools when needed — not worth per-user collection).
