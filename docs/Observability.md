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
| `startup` | `init_ms`, `first_frame_ms` | Every launch ([main.dart](../lib/main.dart)) |
| `screen_view` | `route` (template, e.g. `/products/:id` — never the concrete URI) | Every navigation ([app_router.dart](../lib/core/router/app_router.dart)) |
| `optimize_run` | `items`, `options`, `multi_store_recommended`, `duration_ms` (fetches + solve) | Basket optimization completes |
| `map_ready` | `ms` (screen construction → interactive map) | Map screen first renders |
| `http_request` | `host`, `path`, `status`, `ms` — host+path only, never query strings or bodies | Each external (non-Supabase) HTTP request |
| `pending_ops_drained` | `applied`, `dropped` | Offline check-off queue flushes (reconnect or startup) |
| `receipt_prices_recorded` | `items`, `recorded` | Receipt saved; how many lines became price observations |
| `price_reported` | `has_store` | Community price report submitted |
| `barcode_external_lookup` | `found` | Scanned barcode missed the catalog and was sent to Open Food Facts (measures catalog coverage) |
| `onboarding_complete` | — | First-run walkthrough finished |
| `account_deleted` | `demo` | Deletion **requested** (fires pre-call by necessity: post-deletion there is no session to log with; a failed attempt still counts) |
| `app_error` | `error` (scrubbed + truncated), `type` (runtime type), `fatal` | Any uncaught or recorded error |

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
