# Contributing

## Setup

```bash
flutter pub get
dart run build_runner build
flutter run    # demo mode, no backend needed
```

## Ground rules

- **Architecture**: feature-first Clean Architecture. New features get
  `domain/`, `data/`, `presentation/` folders. Presentation never
  imports data-source packages; failures cross layers as `Failure`.
- **State**: Riverpod, manual providers (no riverpod codegen). Inject
  everything through providers so tests can override.
- **Backends**: every repository needs both a Supabase and a demo
  implementation — demo mode must keep working end to end.
- **Style**: `flutter analyze` clean and `dart format` clean are
  mandatory (CI enforces both). Freezed for entities; snake_case JSON.
- **Tests**: pure logic (optimizer, parsers) gets unit tests; screens
  with logic get widget tests with fake repositories. Run
  `flutter test` before pushing; golden updates via
  `flutter test --update-goldens test/golden`.

## Workflow

1. Branch from `main`: `feat/<topic>`, `fix/<topic>`.
2. Small, focused commits in
   [Conventional Commits](https://www.conventionalcommits.org) format
   (`feat:`, `fix:`, `docs:`, `chore:`, `test:`, `refactor:`).
3. Open a PR against `main`; CI must pass (analyze, format, tests,
   Android + iOS builds).
4. PRs that change architecture or workflow update the relevant doc in
   `docs/` in the same PR.

## Database changes

Add a new timestamped file in `supabase/migrations/` — never edit an
applied migration. Include RLS policies for any new table and update
`docs/Database.md`.
