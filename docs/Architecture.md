# Architecture

Feature-first Clean Architecture on Flutter with Riverpod for dependency
injection and state.

## Layers

```
┌────────────────────────────────────────────────────────┐
│ Presentation   screens, widgets, Riverpod providers    │
│                (ConsumerWidget, AsyncValue)             │
├────────────────────────────────────────────────────────┤
│ Domain         Freezed entities, repository interfaces, │
│                pure business logic (BasketOptimizer,    │
│                ReceiptParser)                           │
├────────────────────────────────────────────────────────┤
│ Data           SupabaseXxxRepository + DemoXxxRepository │
│                per interface; Hive cache; DTO mapping   │
├────────────────────────────────────────────────────────┤
│ Core           config, theme, router, network (Dio),    │
│                storage (Hive), services, AI abstraction │
└────────────────────────────────────────────────────────┘
```

Dependency rule: presentation → domain ← data. The presentation layer
never imports `supabase_flutter`, `dio`, or `hive`; failures cross layer
boundaries as the sealed `Failure` hierarchy
([failures.dart](../lib/core/errors/failures.dart)).

## Dependency injection

Riverpod providers wire everything:

```dart
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  if (AppConfig.isDemoMode) return DemoProductRepository();
  return SupabaseProductRepository(
    ref.watch(supabaseClientProvider),
    ref.watch(localStoreProvider),
  );
});
```

Every repository has an interface in `domain/` and two implementations in
`data/`: a Supabase-backed one and a demo one (seeded, Hive-persisted).
Tests inject fakes by overriding the provider — no service locators, no
singletons in feature code.

## The basket optimizer

`lib/features/shopping_lists/domain/basket_optimizer.dart` — pure Dart,
zero I/O:

1. Take the N nearest candidate stores (default 6).
2. Enumerate all store combinations of size 1–3.
3. Assign each list item to the cheapest store in the combination.
4. Price the trip honestly: `items − coupons + driving cost`, where
   driving is the shortest home→stores→home tour (≤3 stores ⇒ brute-force
   permutations) at the user's configured cost/km.
5. Rank by item coverage first, then total. A multi-store option is only
   *recommended* when it beats the best single store by the user's
   savings threshold.
6. Emit a human explanation per option ("Saves $3.18 vs the best single
   store for about 4 extra minutes — worth it.").

Preferences (fuel cost/km, multi-store threshold) feed in from user
settings.

## AI abstraction

```
feature code ──► AiServices (typed use cases) ──► LlmClient (interface)
                                                    ├── AnthropicClient
                                                    ├── OpenAiClient
                                                    ├── MockLlmClient (demo)
                                                    └── (add yours here)
```

`LLM_PROVIDER`/`LLM_API_KEY` dart-defines select the implementation in
[llm_provider.dart](../lib/core/ai/llm_provider.dart). Swapping providers
touches nothing outside `core/ai/`. For production, point a custom
client at the `ai-proxy` Supabase edge function so API keys stay
server-side.

`AiServices` exposes typed use cases (meal plan, list generation,
substitutions, receipt summary, chat) and owns prompt construction and
JSON parsing. The mock client returns deterministic, well-formed
responses so demo mode exercises the full UI.

## Navigation

GoRouter with a 5-branch `StatefulShellRoute` (Home, Lists, Stores,
Insights, Profile). Detail routes push on the root navigator, covering
the bottom bar. Auth redirect is driven by a `refreshListenable` bound to
`authStateProvider`; demo mode auto-signs-in a local user.

## Offline & sync

- Reads: repositories cache JSON documents in Hive
  (`LocalStore.putJsonList` / `getJsonList` with TTL) and fall back to
  cache on network failure.
- Demo mode: all user data (lists, pantry, receipts, plans) persists in
  Hive via `DemoCollection<T>` so state survives restarts.
- Preferences: local-first, then best-effort upsert to Supabase;
  last-write-wins on conflict (`updated_at`).
- Realtime: `shopping_lists`, `shopping_items`, `notifications` are in
  the Supabase realtime publication for future live-sync UI.

## Error handling

Data sources catch raw exceptions and rethrow typed `Failure`s. UI
consumes `AsyncValue` via `AsyncValueWidget`, which renders skeletons,
retry-able error views, or data. `Result<T>`/`guard()` cover non-async
flows and repository internals.

## Platform notes

- `MainActivity` extends `FlutterFragmentActivity` and themes are
  AppCompat-based — both required by flutter_stripe.
- Google Maps keys are injected via Gradle manifest placeholder
  (`MAPS_API_KEY`) and xcconfig (`GOOGLE_MAPS_API_KEY`); missing keys
  degrade to a banner, never a crash.
- Firebase Messaging initializes defensively; without
  `google-services.json` the app runs with push disabled.
