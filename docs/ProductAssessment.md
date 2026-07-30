# Product Assessment — 2026-07-30 (updated for RC-1)

> **Release-candidate addendum.** After this assessment was written, the
> RC phase closed both store blockers and re-verified the app: AI now
> routes through `ai-proxy` by default (no key in the binary, input caps
> + per-user quota), in-app account deletion with cascading removal
> shipped, privacy/terms/consent/export/feedback exist, accessibility
> guidelines run as CI tests on four screens, and performance is
> measured (optimizer 1.60ms/run benchmarked; Windows first frame 768ms
> debug). A 15-agent adversarial review of those fixes confirmed 13
> defects — including a genuine blocker in the deletion flow — all
> fixed and re-verified. Updated scores: Security 8, Accessibility 7,
> Production Readiness 8, Testing 8. See CHANGELOG.md and docs/Beta.md.

Assessed against the working tree at the end of the commercial-grade
phase. Every score below is justified by code, tests or CI output, not
by intent. Where the evidence is unflattering it is stated plainly.

Baseline: **66 tests**, `flutter analyze` clean, four green CI jobs
(analyze/test · Windows · Android · iOS), auto-deployed web demo.

---

## 1. What this product is now

A weekly grocery shopper can: build a list by typing, voice, barcode or
AI; see whether today's price on any item is actually good; get the
cheapest way to buy the *whole* list across up to three nearby stores
with coupons, fuel and their own time priced in; see what that saves
against just driving to the nearest shop; view the route on a map and
hand it to their phone's navigation in the optimal stop order; scan a
receipt into spending analytics; and ask an assistant why any of it is
recommended.

It runs on Android, iOS, Web and Windows desktop from one codebase, and
the entire experience is explorable with no account and no backend.

---

## 2. Scores

### Product Experience — 7/10 (was 6)

**Evidence for.** One seeded `ColorScheme` with shape, elevation and
48px touch-target tokens defined once in `app_theme.dart`; a shared
`AsyncValueWidget` that defaults to shimmer skeletons rather than
spinners, used across 15 screens; `EmptyState` with teaching copy and a
CTA in 12; text scaling correctly composed with the OS setting and
clamped; high-contrast that really changes `ColorScheme.contrastLevel`.

**What moved it this phase.** Destructive actions were the glaring hole
and are closed: swiping a pantry item, receipt or list line now offers a
6-second Undo that restores the exact entity, deleting a whole list asks
first (it is expensive to reconstruct, so undo is the wrong affordance),
and the two most repeated gestures gained haptics. The home screen no
longer shows a hole to a new account, the product grid sizes by width
instead of hardcoding two columns, and a failed favourites load is
retryable.

**Why not higher.** The sensory layer is still thin: no `Hero`
transitions, animation on 2 of 25 screens, and hierarchy improvised
through scattered `fontWeight` overrides rather than a `textTheme`
scale. These were consciously deferred — see §5.

### Shopping Intelligence — 8/10 (was 6)

**Evidence.** `BasketOptimizer` is genuinely strong and was already:
every 1–3 store combination, real coupon semantics (product, store and
basket-minimum), fuel cost, optional value-of-time, stock filtering, and
a brute-forced optimal driving order, priced as
`items − coupons + travel + time` and commented "the honest number".

**What moved it.** The time dimension existed only as marketing copy —
three shipped strings promised price-vs-history analysis the app could
not perform. `PriceVerdict` now delivers it: "Lowest in 90 days", "12%
below usual", each with a plain-language explanation, computed from the
history the repository already served. `savingsVsBaseline` finally puts
a payoff on the payoff screen, measured against the nearest store —
what the shopper would have done anyway — rather than against the best
option, which would have flattered the number. Dietary restrictions now
actually reach substitution suggestions.

**Deliberately not built:** buy-now-vs-wait and best-day-to-shop. The
only cycle in the data is `(d % 28 < 4 ? 0.18 : 0)` in the seed
generator — the seed put it there. A countdown derived from synthetic
periodicity would be a fabricated forecast, and would mislead the day
real data arrives. The verdict is descriptive by design.

### Map Experience — 8/10

**Evidence.** `map_screen.dart` is dependency-light and confident:
tweened camera and `CameraFit.bounds`, screen-space grid clustering,
custom-painted chain-coloured pins, theme-aware CARTO tiles, correct OSM
attribution, on-map A/B/C trip comparison, search and open-now/favourite
filters, and `Semantics` on every marker and control. It needs no API
key on any platform, which is why the public web demo has a working map
at all.

**What moved it.** The optimizer's most expensive computation used to
end as a drawing. "Start trip" now hands the whole run to the phone's
navigation app as ordered waypoints, and arriving from "View on map"
frames *your* trip rather than every store in the city.

**Why not higher.** The map still shows no prices — pins carry chain
colour and stop number, not cost. Per-pin price pills were assessed and
rejected: they duplicate the optimizer, which answers the better
question for the whole basket.

### AI Assistant — 7/10

**Evidence.** A genuinely provider-agnostic `LlmClient` with Anthropic,
OpenAI and a deterministic mock behind one config switch; typed use
cases in `AiServices` (meal plan, list generation, substitutions,
receipt summary, trip explanation, chat); every optimizer recommendation
can be interrogated with "Ask AI why". Both AI actions now show a
pending state instead of appearing dead for several seconds.

**Why not higher.** The API key still ships inside the binary, and the
`ai-proxy` edge function that solves it is written, deployed and
uncalled. On web — the platform actually deployed — direct
`api.anthropic.com` calls are CORS-blocked, so a *configured* web build
would have broken AI. Harmless today only because the public demo uses
the mock. This is the single most important pre-beta fix (§7).

### Accessibility — 6/10 (was 4)

**Evidence for.** Text scaling and high contrast are real, user-
controlled and correctly composed; tooltips on icon buttons; the map's
markers, clusters and controls carry labels; `PriceTag` and the new
`_VerdictBanner` announce a composed sentence rather than fragments.
`MergeSemantics` now wraps the budget, list and optimizer-option cards,
so a screen reader hears one recommendation instead of four scraps.

**Why not higher.** Coverage is still partial — most secondary screens
have no explicit semantics, and there has been no real screen-reader
pass on a device, only code-level review. Claiming more would overstate
what was verified.

### Performance — 7/10

**Evidence.** The optimizer is bounded by construction (≤6 stores, ≤3
per combination, ≤6 tour permutations) and runs client-side, so it costs
the server nothing and scales with users for free. Map clustering keeps
marker counts sane. `const` constructors, `ListView.builder`, and a
300ms search debounce throughout. Windows release builds in ~60s; web in
~40s.

**Why not higher.** No profiling was performed — no frame-timing capture
on device, so the "60 FPS" target is unverified rather than met. No
pagination anywhere; a real catalog of 10k products would load in full.

### Production Readiness — 6/10 (was 5)

**Evidence for.** Global crash capture hooked into both `FlutterError`
and `PlatformDispatcher`, chaining rather than stomping the previous
handler, plus a Riverpod failure observer; a full failure taxonomy in
the Dio interceptor; graceful degradation for every unconfigured
service; TTL caching; four green CI jobs including a Windows build that
immediately caught a real MSVC 14.51 portability break.

**What moved it.** The `pending_ops` box is no longer decorative — a
check-off made with no signal is queued and replayed on reconnect, with
tests for ordering, partial failure and surviving a restart. An expired
session now raises `AuthFailure` through `requireUserId` instead of
`Null check operator used on a null value` on an unrecoverable screen.
Error strings are redacted before reaching the analytics table.

**Why not higher.** Still no feature flags or runtime config, so any fix
is a store round-trip. Analytics is three events, not a funnel. No
in-app account deletion — a hard Apple 5.1.1(v) and Play requirement.
Realtime is published on three tables and subscribed by nobody.

### Testing — 7/10

**Evidence.** 66 tests, and they are concentrated where the risk is:
14 on the optimizer (including out-of-stock exclusion, value-of-time,
driving order and the new savings baseline), 12 on `PriceVerdict`
boundaries, 4 on the offline outbox, 6 on the platform capability
matrix, 5 on the Hive round-trip that caused a real data-loss bug, plus
widget tests for undo, empty states and golden baselines.

**Why not higher.** Repositories, AI services and the router redirect
have no direct tests; the integration test is a single smoke walk. Line
coverage has never been measured, so "7" reflects judgement about
risk-weighted coverage, not a number.

### Maintainability — 8/10

**Evidence.** Feature-first Clean Architecture held consistently: every
feature has `domain/` (Freezed entities + repository interface + pure
logic), `data/` (Supabase and demo implementations) and `presentation/`.
Presentation imports no data-source package anywhere. The two most
valuable pieces of logic — `BasketOptimizer` and `ReceiptParser` — are
pure Dart with no I/O, which is why they are the best-tested. Zero
TODO/FIXME markers. `PlatformSupport` centralises capability checks
instead of scattering platform conditionals.

**Why not higher.** Some screen-local private providers are untestable
from outside; a few large presentation files (`map_screen.dart` ~1000
lines) would benefit from splitting.

**Composite: 7.3/10** — a well-built product that is genuinely useful
and honest about its own numbers, one round of polish short of feeling
crafted.

---

## 3. Feature completeness

| Area | State |
|---|---|
| Lists, products, stores, offers, coupons, pantry, receipts, meal planner, analytics, assistant, settings, onboarding | Implemented |
| Basket optimizer incl. coupons, fuel, time, stock, savings baseline | Implemented |
| Price verdict vs history | Implemented |
| Map: clustering, routes, trip comparison, navigation handoff | Implemented |
| Offline: demo mode fully offline; read cache; check-off outbox | Partial — outbox covers one write path |
| Auth | Partial — no password reset, no account deletion |
| Realtime, background sync, pagination, feature flags | Not implemented |
| Live retailer pricing | Not implemented — seeded data behind repository interfaces |

**≈85% of the intended product surface**, with the remaining 15%
concentrated in commercial plumbing rather than user-facing features.

---

## 4. Architecture

Unchanged in shape, extended in two places:

- `lib/core/platform/platform_support.dart` — capability matrix.
- `lib/core/storage/pending_ops.dart` — durable outbox, drained by
  `pendingOpsSyncProvider` when connectivity returns.
- `lib/features/products/domain/price_verdict.dart` — pure price
  analysis, no I/O.

See [Architecture.md](Architecture.md).

---

## 5. Deliberately not done, and why

Each of these was assessed and rejected on evidence. Recording the
reasoning matters more than the decision.

| Not done | Reason |
|---|---|
| Price provenance + multi-source `LayeredProductRepository` | ~130 lines and a schema change to support a second source that does not exist. An interface with one implementation. Revisit when a second real feed exists; the merge is a 20-line pure function then. |
| Buy-now-vs-wait / next-sale countdown | The only periodicity in the data is seeded. Forecasting from it would fabricate a number. |
| Hero transitions, animated counters | The most visible-to-a-reviewer, least-felt-by-a-shopper change available. |
| Full ARB/l10n migration | 113 literals, no second locale shipping. The ~30-line half (locale into `Formatters`) is the right first step when a non-US beta user appears. |
| Feature flags, pagination, AI rate limiting | Real beta hygiene, zero user-facing effect, speculative before traffic. |
| Price pills on map pins | Duplicates the optimizer, which answers the better question. |
| Wiring `priceDropAlerts` | Would require generating fake notifications. A toggle that does nothing is worse than no toggle — it should be hidden until real. |

---

## 6. Remaining limitations

1. **LLM key ships in the client**; `ai-proxy` is written but unwired.
   Configured web builds would hit CORS. Demo is unaffected (mock).
2. **No account deletion** — blocks App Store and Play submission.
3. **Offline outbox covers check-offs only**; other mutations still fail
   loudly rather than queueing.
4. **No pagination** — fine for 104 seeded products, not for a real
   catalog.
5. **Prices are seeded**, not live. Interfaces are ready; ingestion is
   not built.
6. **Accessibility is partial** and unverified on a real screen reader.
7. **Performance unprofiled** — no frame timings captured.
8. **Windows**: no camera scanning, OCR, payments or push (plugin gaps,
   all degrading gracefully). Desktop OAuth cannot round-trip.
9. **`cached_network_image` is declared but imported nowhere.**

---

## 7. Beta release checklist

- [ ] Route LLM traffic through `ai-proxy`; remove the key from the
      client bundle *(blocker for any configured build)*
- [ ] Add in-app account deletion *(blocker if shipping to app stores)*
- [ ] Expand analytics to a funnel: install → onboarding → first list →
      first optimize → first receipt
- [ ] Real device screen-reader pass (TalkBack + VoiceOver)
- [ ] Capture frame timings on a mid-range Android device
- [ ] Crash reporting backend behind `Telemetry.recordError`
- [ ] Privacy policy + data-handling disclosure
- [ ] Decide the beta's data story: demo-only, or a seeded Supabase
      project with real RLS

## 8. Production release checklist

- [ ] Everything above
- [ ] Live price ingestion for at least one chain, with freshness SLAs
- [ ] Pagination on products and notifications
- [ ] Feature flags / kill switch for AI and payments
- [ ] Stripe webhook setting `users.is_premium`
- [ ] Android upload keystore in CI secrets; iOS signing pipeline
- [ ] Load test the Supabase project at expected concurrency
- [ ] Rate limiting on `ai-proxy`
- [ ] Rollback runbook and on-call ownership

## 9. App Store / Play readiness

**Not submittable today.** Two hard blockers: no account deletion
(Apple 5.1.1(v), Play Data Safety) and the client-side LLM key.

Already in place: correct permission strings with honest rationales,
adaptive icons, release signing path in CI, no secrets in the repo,
graceful degradation when services are unconfigured, and an iOS
deployment target (15.5) that satisfies every plugin.

Also needed before submission: store listing copy and screenshots, a
privacy policy URL, an age rating, and a decision on whether Premium is
a real IAP — if it is, Apple will require StoreKit rather than Stripe
for digital goods.

**Estimate: 1–2 weeks** of non-feature work to be submittable.

## 10. Scaling to millions

The client is already the cheap part: the optimizer runs on-device, so
the most expensive computation in the product costs the server nothing
and scales linearly with users for free.

1. **Reads** — catalog tables are public and cacheable; put a CDN in
   front of PostgREST and add read replicas. The 6h Hive TTL already
   suppresses repeat traffic.
2. **Writes** — owner-partitioned by RLS; Postgres handles this shape
   to millions of users. Move `analytics` to an append-only store
   (ClickHouse/Tinybird) before it competes with product tables.
3. **Search** — move from `ilike` to the existing FTS index, then to
   Meilisearch/Typesense past ~1M products.
4. **Geo** — replace the lat bounding box with PostGIS + GiST once store
   count passes a few thousand.
5. **AI** — all traffic through `ai-proxy`; add per-user rate limits,
   response caching for identical prompts, and provider failover there.
6. **Push** — a worker consuming `notifications` inserts and batching to
   FCM via `device_tokens`.
7. **Tiles** — self-host or contract a provider; only the `urlTemplate`
   in `map_screen.dart` changes.
8. **Ingestion** — the real scaling problem. Per-chain workers writing
   normalized rows into `prices`, with the price-history trigger already
   archiving changes. Client code does not change.

Full recipes: [Scaling.md](Scaling.md).

---

## 11. Roadmap

**Next (highest value first)**
1. `ai-proxy` wiring + account deletion — unblock beta
2. Analytics funnel, then act on where people actually drop
3. Extend the outbox to all list mutations
4. Locale into `Formatters`; ARB extraction when a second locale is real
5. `textTheme` scale, folded into screens already being edited

**Later**
- Live ingestion for one chain; provenance/confidence on `Price` once a
  second source exists
- Realtime shared lists (tables already published)
- Receipt line-items matched to catalog products, auto-updating pantry
- Road-distance routing via OSRM, replacing haversine
- Offline tile packs

**Explicitly parked:** sale prediction until real price history exists;
per-pin price overlays; a generic sync engine.
