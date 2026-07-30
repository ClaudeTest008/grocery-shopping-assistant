# Grocery Shopping Assistant

**▶ Live demo (no install): <https://claudetest008.github.io/grocery-shopping-assistant/>**

AI-powered grocery shopping assistant that finds the **cheapest and smartest
way to complete an entire grocery trip** — not just compare item prices.

Give it a shopping list and it compares every nearby store, prices the
whole basket (including your clipped coupons **and the cost of driving
there**), and tells you whether splitting the trip across two or three
stores is actually worth it:

```
Option A  Everything at Aldi            $41.22
Option B  Aldi + Walmart                $38.04   (+4 min drive)
          Savings $3.18 — worth it ✓
```

## Features

- **Basket optimizer** — the core engine. Single vs multi-store trip
  analysis with fuel cost, travel time, coupon savings, stock awareness
  and honest explanations of *why* a recommendation wins — including
  what it saves against just driving to your nearest store.
- **Price verdict** — "Lowest in 90 days", "12% below usual": every
  product says whether today's price is actually good, from its own
  recorded history.
- **Shopping lists** — create, duplicate, voice input, barcode add,
  AI-generated lists ("dinners for 4 under $60").
- **Products** — search, categories, nutrition, unit prices, price
  history charts, cheaper alternatives.
- **Interactive map** — key-free OpenStreetMap tiles, animated camera,
  marker clustering, optimizer route polylines with numbered stops,
  search/filters, store bottom sheets, dark tiles.
- **Offers & coupons** — weekly ads, digital coupons with clip-to-wallet,
  cashback, expiry alerts.
- **Meal planner** — AI weekly plans that use up pantry items and
  currently discounted products.
- **Pantry** — inventory with expiration tracking and use-it-up nudges.
- **Receipt scanner** — on-device OCR (ML Kit) → structured receipts →
  spending analytics and pantry updates.
- **Budget & insights** — monthly spending, category breakdown,
  next-month forecast (fl_chart).
- **AI assistant** — natural-language chat: "Should I wait until next
  week?", "Replace expensive products", "Find vegan alternatives".
- **Offline-first** — Hive cache, demo mode with zero backend.

## Tech stack

Flutter (Android · iOS · Web · Windows Desktop) · Riverpod 3 · GoRouter · Material 3 ·
Supabase (PostgreSQL, Auth, RLS, Realtime, Edge Functions) · Firebase
Messaging · flutter_map (OpenStreetMap) · Hive · Freezed · Dio ·
fl_chart · Google ML Kit · mobile_scanner · speech_to_text · Stripe ·
GitHub Actions (CI + Pages auto-deploy).

## Quick start

```bash
git clone https://github.com/ClaudeTest008/grocery-shopping-assistant.git
cd grocery-shopping-assistant
flutter pub get
dart run build_runner build
flutter run          # runs in demo mode — no backend needed
```

On Windows, one command starts the whole local environment (packages,
codegen, then desktop **and** Chrome side by side):

```bat
dev
```

See [Development.md](Development.md) for the full workspace guide,
developer scripts and desktop platform notes.

**Demo mode**: with no `--dart-define` configuration the app boots
against a seeded local dataset (6 Austin stores, 26 products, live-ish
prices, offers, coupons) persisted in Hive. Every feature works,
including the optimizer and the AI assistant (deterministic mock LLM).

### Connecting real services

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://<project>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<anon-key> \
  --dart-define=LLM_PROVIDER=anthropic \
  --dart-define=LLM_API_KEY=sk-ant-... \
  --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_...
```

See [docs/Deployment.md](docs/Deployment.md) for Supabase setup, Google
Maps keys, Firebase config, and store releases.

## Project structure

```
lib/
  core/        config, theme, router, network, storage, AI abstraction
  shared/      reusable widgets, extensions, cross-feature models
  features/    feature-first Clean Architecture
    <feature>/
      domain/        entities (Freezed) + repository interfaces + pure logic
      data/          Supabase + demo repository implementations
      presentation/  screens, widgets, Riverpod providers
supabase/      migrations, RLS policies, seed, edge functions
test/          unit, widget, golden tests
integration_test/
```

Details: [docs/Architecture.md](docs/Architecture.md) ·
[docs/Database.md](docs/Database.md) · [docs/API.md](docs/API.md) ·
[docs/Testing.md](docs/Testing.md) · [docs/Roadmap.md](docs/Roadmap.md)

## Development

```bash
flutter analyze                                   # zero-warning policy
flutter test                                      # unit + widget
flutter test --update-goldens test/golden         # regenerate goldens
dart run build_runner watch -d                    # codegen during dev
```

Contributions welcome — see [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT
