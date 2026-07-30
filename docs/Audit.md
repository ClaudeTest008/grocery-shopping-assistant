# Engineering Audit — 2026-07-10

Method: every claim below verified against the working tree at commit
`8d4ce04` (file reads, greps, `flutter analyze`, `flutter test`, GitHub
Actions run inspection). Metrics: **10,112** hand-written Dart LOC in
`lib/` (+36 generated files), **601** test LOC, **0** TODO/FIXME
markers, **27/27** tests passing, `flutter analyze` clean.

---

## Part 1 — Architecture audit

| Category | Score | Evidence & rationale |
|---|---:|---|
| Project structure | 9 | Feature-first: `lib/features/<15 features>/{domain,data,presentation}` + `core/` + `shared/`. Matches docs exactly. |
| Feature organization | 9 | Every feature has domain entities (Freezed), repository interface, dual data impls, screens. One deviation: notifications live in `shared/` (no feature folder). |
| Dependency injection | 8 | Riverpod providers throughout (`productRepositoryProvider` in `product_repositories.dart` etc.); demo/Supabase switch at provider level; tests override providers. −2: a few screen-local private providers (`_monthSpendProvider` in `home_screen.dart`) are untestable from outside. |
| Routing | 8 | `app_router.dart`: GoRouter 17, `StatefulShellRoute.indexedStack` (5 branches), auth redirect via `refreshListenable` bound to `authStateProvider`, deep-linkable paths. −2: no route transition animations, no 404 handler, no typed routes. |
| State management | 8 | Riverpod 3.3, manual providers, `AsyncValue` everywhere via shared `AsyncValueWidget`. −2: invalidate-based refresh causes full reloads (no optimistic updates, e.g. coupon clip reloads whole list). |
| Error handling | 8 | Sealed `Failure` hierarchy (`core/errors/failures.dart`), Dio interceptor maps transport errors, `Result<T>`/`guard()`. −2: no global `FlutterError.onError`/zone handler; `store_detail_screen._directions` calls `launchUrl` unguarded. |
| Repository layer | 9 | Interface per feature in `domain/`, `Supabase*` + `Demo*` impls in `data/`; presentation never imports supabase/dio/hive (verified by import grep). |
| Domain layer | 9 | Pure logic where it matters: `BasketOptimizer` (289 lines, zero I/O), `ReceiptParser`; Freezed entities with behavior (`Store.isOpenNow`, `Coupon.valueOn`). |
| Data layer | 8 | Snake-case JSON matching Postgres, embedded selects, Hive cache-aside with TTL in `SupabaseProductRepository.pricesFor`. −2: only prices have offline fallback; other Supabase repos have no cache path. |
| Testing strategy | 6 | Strong core-engine coverage (9 optimizer, 4 parser tests) + widget/golden/integration. −4: 601 test LOC vs 10k source; zero tests for AI services, repositories, router redirect, most screens. |
| Offline support | 5 | Demo mode fully offline (Hive-persisted `DemoCollection`); connected mode: read cache only for prices. **`pending_ops` Hive box exists in `LocalStore` but nothing writes to it — the offline write queue is declared, not implemented.** No conflict resolution beyond prefs last-write-wins. |
| Caching | 7 | `LocalStore.putJsonList/getJsonList` with `maxAge`; 6h TTL on prices; image caching via `cached_network_image`. −3: no cache for stores/offers/coupons, no invalidation strategy documented. |
| Performance | 7 | Const constructors, `ListView.builder`, debounced search (300ms), bounded optimizer search space (6 stores max). −3: no pagination anywhere, coupon clip re-fetches list, no `RepaintBoundary` on charts, marker set rebuilt every frame on map. |
| Security | 7 | Secrets via `--dart-define` only, none committed; RLS owner-only policies; edge functions validate JWT. −3: `StripeService.presentPaywall` POSTs to the edge function **without Authorization header** → will 401 against real backend; no certificate pinning; no input length limits on AI prompts. |
| Authentication | 7 | Email + Google + Apple via Supabase OAuth (`SupabaseAuthRepository._oauth`, deep link `com.groceryassistant.grocery://login-callback`); demo auto-auth. −3: no password reset, no email verification UX, no session refresh error handling. |
| Configuration | 8 | `AppConfig` compile-time dart-defines with safe defaults; graceful degradation matrix (no key → demo/mock/banner). −2: no runtime remote config; iOS Maps key plumbing via xcconfig is documented but not scaffolded in the repo's xcconfigs. |
| Environment handling | 7 | Demo vs configured detection (`AppConfig.isDemoMode`). −3: no staging concept, no per-env Supabase project switching, `.env.example` referenced in .gitignore but file absent. |
| Scalability | 7 | Stateless client + Postgres + RLS scales horizontally; bounding-box store prefilter. −3: no pagination on products/notifications; nearby-store query scans by lat only; price ingestion pipeline absent. |
| Technical debt | 8 (low debt) | Zero TODOs; consistent style. Known debt: dead `pending_ops` box, `SpeechToText` not stopped in `ListDetailScreen.dispose`, `_uuid`-style duplicate helpers in 3 files, `'demo-user'` string fallback in 4 screens instead of a constant. |

**Verified broken in CI** (run 29056790313 on `main`): `Analyze & test` ✅, `Android build` ✅, **`iOS build` ❌** — `google_maps_flutter_ios` requires higher min iOS than the default Podfile target. **`release.yml` fails to parse** (0 jobs): `secrets` context used in a step-level `if`, which GitHub Actions forbids.

---

## Part 2 — Interactive map audit

1. **Technology**: Google Maps (native SDKs via platform views).
2. **Package**: `google_maps_flutter 2.17.1`.
3. **Screens with maps**: exactly one — `MapScreen` (`lib/features/maps/presentation/map_screen.dart`, 135 lines). `StoreDetailScreen` has a "Directions" button that *launches the external* Google Maps app; no embedded map.
4. **Interactive?** Only at the level the SDK gives for free.
5. Capability matrix (verified against `map_screen.dart` source):

| Capability | Status |
|---|---|
| Zoom / rotate / tilt | ✅ SDK default gestures (no custom controls) |
| Search | ❌ Not implemented. |
| GPS / follow location | ❌ `myLocationEnabled: false`; no location button |
| Tap markers | ✅ `Marker.onTap` → `setState(_selected)` |
| View store details | ✅ bottom Card → `/stores/:id` |
| Navigation | ❌ on map (external launch only, from store detail) |
| Nearby stores / multiple stores | ✅ all stores from `nearbyStoresProvider` as markers |
| Filter stores | ❌ Not implemented. |
| Store overlays / basket routes / shopping routes / optimized routes / route comparison | ❌ Not implemented — **zero polylines anywhere** (grep: no `Polyline` usage) |
| Traffic / live location / compass / scale bar | ❌ Not implemented. |
| Marker clustering / animated markers / camera animation / marker animation | ❌ Not implemented — no `animateCamera` call, no `GoogleMapController` even captured |
| Dark mode | ❌ default map style only |
| Offline / tile caching / vector maps | ❌ Not implemented. |
| Heat maps / price overlays / coupon overlays | ❌ Not implemented. |
| Opening hours / parking / accessibility / delivery / pickup | ❌ on map (hours exist on store detail screen only) |
| Favorites / recently visited | ❌ Not implemented. |

6. Basket optimization → map update: **No.** `OptimizeScreen` and `MapScreen` share nothing; optimizer results never reach the map.
7. Route selection camera animation: **No.**
8. Optimizer route polylines: **No.**
9. Optimizer calculates: driving distance (haversine tour), fuel cost, time (35 km/h heuristic + 8 min/stop) — in `BasketOptimizer`. Walking/cycling/transit: **Not implemented.**
10. Compare multiple trips: ✅ but as **cards on OptimizeScreen**, not on the map.
11. Tap store → inspect offers: ✅ two taps away (marker → View store → offers section). Not on-map.
12. Start navigation: ✅ external only (store detail → Google Maps URL).
13. Reorder routes: **Not implemented.**
14. Drag markers: **Not implemented.**
15. Save routes: **Not implemented.**
16. Tablet: map fills screen (works) but no adaptive two-pane layout.
17. Performance: 100 stores — fine (marker set built in one pass). 1,000 — degraded: markers rebuilt in `build()` on every `setState`, no clustering. 10,000 — unusable without clustering/viewport culling.
18. **Overall map score: 3/10.** A functional store-pin viewer with a detail card; none of the product-defining map features exist. Also renders **blank tiles without an API key**, which is the default demo state — the app's weakest screen.
19. Missing: everything in the ❌ rows above, plus any key-free tile source for the demo.

---

## Part 3 — Feature audit

| Feature | Status | Evidence |
|---|---|---|
| Authentication | **Partial** | Email/Google/Apple + demo (`auth_repositories.dart`); no password reset/verification flows. |
| Shopping lists | **Implemented** | CRUD, duplicate, check-off, voice (`speech_to_text`), barcode add, AI generation (`list_detail_screen.dart`). |
| Basket optimizer | **Implemented** | `BasketOptimizer` engine + `OptimizeScreen` comparison UI + coupons + travel cost; 9 unit tests. |
| Coupons | **Implemented** | clip/unclip persisted, expiry emphasis, copy code. |
| Offers | **Implemented** | grouped weekly ads, badges, expiring-soon. No detail screen. |
| Stores | **Implemented** | nearby w/ distance & drive time, open-now, hours, call/directions. |
| Products | **Implemented** | search+debounce, categories, nutrition, alternatives, unit price. No images (icon placeholders), no pagination. |
| Price history | **Implemented** | fl_chart line + low/avg/high stats; synthetic in demo; Postgres trigger archives real changes. |
| Meal planner | **Implemented** | AI weekly plan, pantry-aware chips, add-missing-to-list, regenerate. |
| Receipts | **Implemented** | history, expandable items, delete. |
| OCR | **Implemented** | ML Kit `TextRecognizer` → `ReceiptParser` (4 unit tests) → editable confirm → save; manual fallback. |
| Barcode scanner | **Implemented** | `mobile_scanner` w/ torch; no permission-denied UX. |
| Pantry | **Implemented** | locations, expiry chips, swipe-delete, add/edit sheet. |
| Notifications | **Partial** | in-app inbox + FCM plumbing (`NotificationService`); no local scheduling, no push fan-out worker, demo-seeded only. |
| Analytics (user-facing) | **Implemented** | budget progress, 6-month bars, category pie, linear-regression forecast (`insights_screen.dart`). |
| AI assistant | **Implemented** | chat w/ suggestions, typing indicator, provider-agnostic (`AiServices`, `LlmClient`); mock offline. |
| Settings | **Implemented** | theme/contrast/text-scale/currency/units/budget/dietary/notifications/trip-cost knobs. |
| Search | **Partial** | products only; no global search, no store/coupon search. |
| Voice | **Partial** | list input only; no assistant voice mode. |
| Accessibility | **Partial** | text scaling applied app-wide (`app.dart` builder), high-contrast flag stored but **not applied to theme**, tooltips present; **zero `Semantics` widgets in `lib/`** (grep-verified). |
| Offline | **Partial** | demo fully offline; connected mode read-cache for prices only; write queue **Not implemented** (dead `pending_ops` box). |
| Realtime | **Not implemented (client).** Tables are in the Supabase publication; no `.stream()`/channel subscription exists in `lib/` (grep-verified). |
| Background sync | **Not implemented.** |
| Flutter Web | **Not implemented.** No `web/` directory. |
| Windows/desktop | **Not implemented.** Only `android/`, `ios/` platform dirs exist. |
| Android | **Implemented** | builds in CI (debug), permissions + Maps placeholder + AppCompat/FragmentActivity for Stripe. |
| iOS | **Partial** | permission strings + deep link + guarded `GMSServices`; **CI build fails** on `google_maps_flutter_ios` min-deployment-target. |
| Maps | **Partial (3/10)** | see Part 2. |

---

## Part 4 — UI/UX audit (per screen, 1–10)

Consistency notes first: all screens share `AsyncValueWidget` (skeleton/error/retry), `EmptyState`, `SectionHeader`, `context.colors/text` theming — dark mode safe throughout (`withValues(alpha:)`, no hardcoded surface colors found). Systemic gaps: no `Semantics` labels; pull-to-refresh only on Stores; deletes have no undo; no hero/route animations.

| Screen | Score | Notes |
|---|---:|---|
| Sign in | 8 | M3 form, validation, autofill, OAuth buttons, demo banner; no password reveal. |
| Home | 8 | budget card w/ progress, active-list card, quick actions grid (tablet-aware 3→6 cols), offers carousel, unread badge. |
| Shopping lists | 8 | progress bars, create dialog, dup/delete menu, empty state. |
| List detail | 8 | voice/barcode/AI inputs, swipe-delete, budget-vs-estimate warning; SpeechToText leak in dispose. |
| Optimize (basket) | 9 | best screen: recommended badge, A/B/C labels, cost facts row, per-store breakdown, honest explanations. |
| Products | 8 | debounced SearchBar, category chips, grid; icon-only images. |
| Product detail | 8 | price table w/ cheapest badge, history chart + stats, nutrition, alternatives. |
| Barcode scan | 6 | works; no permission-denied or camera-error UI. |
| Stores | 8 | pull-to-refresh, open/closed chips, distance+drive time. |
| Store detail | 7 | hours table, offers, unguarded launchUrl. |
| Map | **3** | pins + card only; blank tiles without key; see Part 2. |
| Offers | 7 | grouped, badges; cards not tappable, no refresh. |
| Coupons | 8 | clip/copy/expiry; reload-on-toggle jank. |
| Pantry | 8 | grouped by location, expiry tinting, edit sheet. |
| Receipts | 7 | expandable cards; no undo on delete. |
| Receipt scan | 8 | camera/gallery → OCR → editable confirm → AI summary; graceful ML Kit failure path. |
| Meal planner | 8 | pantry-covered ingredient chips, add-missing-to-list. |
| AI assistant | 8 | bubbles, suggestions, typing indicator, clear. |
| Insights | 8 | 4 chart sections, degrade gracefully <2 months data. |
| Profile | 8 | favorites sheet, premium card, confirm sign-out. |
| Settings | 8 | complete knob set; high-contrast switch currently cosmetic. |
| Notifications | 7 | type icons, mark-all-read, deep links. |

**Average ≈ 7.5; median 8.** The app looks like a coherent, professional M3 product everywhere except the map.

---

## Part 5 — Demo audit

| Item | Status | Evidence |
|---|---|---|
| Demo login | ✅ | `DemoAuthRepository` auto-signs-in "Demo Shopper"; any credentials accepted; banner on sign-in. |
| Seed products | ✅ 26 | `DemoSeed.products` (dairy/produce/meat/bakery/pantry/beverages/frozen). |
| Seed stores | ✅ 6 | Austin: Aldi, Walmart, Kroger, Target, H-E-B, Trader Joe's w/ hours & coords. |
| Coupons | ✅ 4 | incl. store-bound, product %, basket min-spend. |
| Price history | ✅ | deterministic 90-day synthetic series w/ sale dips (`DemoSeed.priceHistory`). |
| Receipts | ✅ 12 weeks | powers budget charts & forecast. |
| Pantry | ✅ 10 items | incl. expiring items for alert demo. |
| Meal plans | ⚠️ generated on demand (mock AI), not pre-seeded. |
| AI chats | ⚠️ suggestion chips + deterministic replies; **no pre-seeded conversation**. |
| Budgets | ⚠️ user must set monthly budget in Settings; not pre-seeded. |
| Charts | ✅ fully populated from seeded receipts. |
| Shopping trips | ✅ seeded 10-item list w/ $60 budget → optimizer produces real A/B/C comparison. |
| Walkthrough / onboarding / guided tour / tooltips (first-run) | ❌ **Not implemented.** |
| Sample notifications | ✅ 4 seeded (price drop, coupon expiry, sale, pantry). |
| Demo reset | ❌ **Not implemented** (must clear app storage manually). |

---

## Addendum — resolved after this audit (same day)

The audit above is the frozen "before" snapshot at `8d4ce04`. The
following findings were fixed in the milestone work that followed:

| Finding | Resolution |
|---|---|
| Map 3/10, blank without key | Rebuilt on flutter_map/OSM: key-free tiles, animated camera, clustering, route polylines, trip overlay, store sheet, filters, dark tiles. Re-scored ≈8/10 (missing: real road routing, offline tile packs). |
| No web target | `web/` enabled; auto-deployed demo at <https://claudetest008.github.io/grocery-shopping-assistant/> on every push to main. |
| iOS CI failure (google_maps_flutter_ios) | Plugin removed with the map migration. |
| release.yml parse error (`secrets` in step `if`) | Emptiness check moved into the script body. |
| High-contrast toggle cosmetic | Now feeds `ColorScheme.fromSeed(contrastLevel: 1.0)`. |
| Stripe checkout unauthenticated | Supabase session bearer + apikey headers added; sign-in guard. |
| `SpeechToText` leak in ListDetailScreen | `cancel()` in dispose. |
| No onboarding / demo reset / seeded AI chat / demo button | All added (Milestone 3). |
| No global error capture / telemetry | `Telemetry` + provider observer + optimize_run event. |
| Zero Semantics | Labels added to map markers, clusters, home pin, PriceTag. Broad per-screen pass still open. |
| Optimizer ignores stock / time value | `Price.inStock` + `valueOfTimePerHour` in totals, both tested. |

Still open (tracked in Roadmap): `pending_ops` offline write queue,
realtime client subscriptions, pagination, password reset, full
Semantics coverage, offline tile packs, road-distance routing.

## Addendum 2 — Windows Desktop platform (2026-07-30)

The audit above recorded "Windows/desktop: **Not implemented**". The
project is now a four-target Flutter app: **Android, iOS, Web, Windows**.

Two findings came out of *running* the app rather than building it — the
first time it had ever been executed rather than compiled:

1. **Persisted data failed to load on the second launch, on every
   platform.** Hive decodes stored maps as `Map<dynamic, dynamic>` at
   every nesting level; `Map<String, dynamic>.from()` converts only the
   outermost one, so the `as Map<String, dynamic>` casts inside generated
   `fromJson` threw for any nested object or list-of-objects. Shopping
   lists, receipts, meal plans and preferences were all affected. Fixed
   with a recursive `LocalStore.normalizeJsonMap`, pinned by round-trip
   regression tests. Builds, `flutter analyze` and the widget tests could
   never have caught this — none of them round-trip through Hive.
2. The `Telemetry` handler added in Milestone 5 is what surfaced it,
   which is the first evidence that the observability layer earns its
   keep.

Windows-specific plugin gaps are handled by
`lib/core/platform/platform_support.dart` (capability matrix, unit
tested) rather than by removing features — see the limitations table in
[../Development.md](../Development.md).

Still open from the original audit: `pending_ops` offline write queue,
realtime client subscriptions, pagination, password reset, full Semantics
coverage, offline map tiles, road-distance routing. New tech debt:
`cached_network_image` is declared in `pubspec.yaml` but imported
nowhere.

## Priority findings (feed into roadmap)

1. **Map is the weakest feature by far (3/10)** and needs a key-free tile source to ever demo well.
2. **No web target** → no live demo possible today.
3. **CI red on main**: iOS min-target (google_maps_flutter_ios) + release.yml parse error (`secrets` in step `if`).
4. Accessibility: zero Semantics; high-contrast toggle cosmetic.
5. Stripe checkout call unauthenticated (would 401 in production).
6. Dead `pending_ops` box — implement or remove.
7. `SpeechToText`/controller cleanup in `ListDetailScreen.dispose`.
8. No onboarding, no demo reset, AI conversation not pre-seeded.
