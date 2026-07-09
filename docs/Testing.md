# Testing

## Layout

```
test/
  core/                      Result/guard semantics
  features/
    shopping_lists/          BasketOptimizer unit tests (the core engine)
                             + ShoppingListsScreen widget tests
    receipts/                ReceiptParser OCR-text parsing
    coupons/                 Coupon value math
  shared/                    shared widget tests
  golden/                    golden baselines (tagged `golden`)
integration_test/            device smoke test (boot + shell navigation)
```

## Running

```bash
flutter test                                  # everything except device tests
flutter test --exclude-tags=golden            # what CI runs
flutter test --update-goldens test/golden     # regenerate golden PNGs
flutter test integration_test/app_test.dart   # needs emulator/device
flutter test --coverage                       # lcov.info in coverage/
```

## Conventions

- **Pure logic first.** The highest-value coverage is the pure Dart
  domain layer: `BasketOptimizer` (store combos, coupons, travel cost,
  coverage ranking, thresholds) and `ReceiptParser` run entirely without
  mocks.
- **Widget tests use fake repositories** injected via
  `ProviderScope(overrides: [...])` — see
  `shopping_lists_screen_test.dart` for the pattern. No network, no
  Hive.
- **Golden tests** are tagged `golden` (see `dart_test.yaml`) and
  excluded in CI because font rendering differs across hosts;
  regenerate locally when shared widgets change.
- **Integration test** boots the real `main()` in demo mode (no backend
  required) and walks the bottom-nav shell.
- `mocktail` is available for interaction-style mocking when a hand
  fake is awkward.

## What CI enforces

1. `dart format --set-exit-if-changed`
2. `flutter analyze` (zero errors)
3. `flutter test --coverage --exclude-tags=golden`
4. Android debug build + iOS no-codesign build
