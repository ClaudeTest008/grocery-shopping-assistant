# Development Guide

VS Code workspace guide for the Grocery Shopping Assistant. New team
members should be running the app within ten minutes.

## Opening the Project

```bash
git clone https://github.com/ClaudeTest008/grocery-shopping-assistant.git
code grocery-shopping-assistant
```

Install the recommended extensions when VS Code prompts (they come from
`.vscode/extensions.json`). Then either press **F5** or run the
**Flutter: Pub Get** task followed by **Build Runner: Build**
(`Ctrl+Shift+P` → "Tasks: Run Task") — Freezed/json_serializable code
must be generated once before the first build.

The app boots in **demo mode** with no configuration: seeded stores,
products, prices, and a mock AI. Real backends connect via
`--dart-define` (see [docs/Deployment.md](docs/Deployment.md)).

## Running the App

Press **F5** and pick a launch profile, or use a terminal.

### Web (Chrome)

- Launch profile **Flutter: Web (Chrome)**, or `flutter run -d chrome`.
- Fastest way to try the app on a fresh machine — no emulator needed.

### Android Emulator

- Start an emulator (`Ctrl+Shift+P` → "Flutter: Launch Emulator"), then
  launch profile **Flutter: Android Emulator**, or
  `flutter run -d emulator`.

### Connected Device

- Enable USB debugging, plug in, verify with `flutter devices`, then
  **Flutter: Connected Android Device**.

### iOS Simulator

- macOS only: **Flutter: iOS Simulator**, or `flutter run -d ios`.
  On Windows/Linux this profile is unusable — expected.

**Profile Mode** / **Release Mode** profiles prompt for a device and are
for performance work; hot reload is debug-only.

## Hot Reload & Hot Restart

- Saving a Dart file hot-reloads automatically
  (`dart.flutterHotReloadOnSave: always` is configured).
- Terminal: `r` = hot reload, `R` = hot restart.
- Debug toolbar: ⚡ = reload, ↻ = restart.
- Hot reload cannot apply changes to `main()`, `initState` of already
  live widgets, enum values, or generated files — hot restart those.

## Debugging

- Set breakpoints in the gutter; F5 stops on them; hover to inspect.
- **Debug Console** evaluates expressions in the paused frame.
- **Widget Inspector**: `Ctrl+Shift+P` → "Flutter: Open Widget
  Inspector" — select widgets on device, inspect constraints.
- **DevTools** (memory, performance, network): link appears in the
  Debug Console on launch.

## Testing

```bash
flutter test                                   # everything (excl. device tests)
flutter test test/features/shopping_lists     # one directory
flutter test --coverage                       # coverage/lcov.info
flutter test --update-goldens test/golden     # regenerate golden PNGs
flutter test integration_test/app_test.dart   # needs emulator/device
```

In the editor, `Run | Debug` CodeLens links appear above every `test()`
and `testWidgets()`. Tasks: **Flutter: Test** (default test task,
`Ctrl+Shift+P` → "Tasks: Run Test Task") and **Flutter: Test with
Coverage**.

Golden tests are tagged `golden` and excluded in CI; regenerate locally
when shared widgets change.

## Code Analysis & Formatting

- Format-on-save and organize-imports-on-save are configured for Dart
  files; the project is `dart format` clean and CI enforces it.
- `flutter analyze` must stay at **zero issues** (CI enforces).
- Tasks: **Flutter: Analyze**, **Dart: Format**.

## Code Generation

Freezed entities and JSON serializers are generated:

- **Build Runner: Build** — one-shot generation
  (`dart run build_runner build --delete-conflicting-outputs`).
- **Build Runner: Watch** — regenerates on save while developing
  entities.
- Generated files (`*.freezed.dart`, `*.g.dart`) are committed, excluded
  from search, and never edited by hand.

## Building Releases

```bash
flutter build web      # deployed automatically by CI on push to main
flutter build apk      # Android APK (flutter build appbundle for Play)
flutter build ios      # macOS only; signing in your pipeline
```

See [docs/Deployment.md](docs/Deployment.md) for dart-defines, signing,
and the GitHub Pages pipeline.

## Useful VS Code Shortcuts

| Shortcut | Action |
|---|---|
| `F5` | Start debugging (launch profile) |
| `Ctrl+F5` | Run without debugging |
| `Shift+F5` | Stop |
| `Ctrl+Shift+P` | Command palette |
| `Ctrl+Shift+B` | Run build task |
| `Ctrl+.` | Quick fix / refactor (wrap with widget…) |
| `F12` / `Alt+F12` | Go to / peek definition |
| `Ctrl+Shift+F` | Search project (generated files excluded) |
| `` Ctrl+` `` | Toggle terminal |

## Troubleshooting

- **Weird build errors** → `flutter clean && flutter pub get`, then
  **Build Runner: Build**.
- **Analyzer acting stale** → `Ctrl+Shift+P` → "Dart: Restart Analysis
  Server".
- **Device not showing** → `flutter doctor -v`, `adb devices`
  (Android), cable/USB-debugging check.
- **Duplicate-class errors in `*.freezed.dart`** → stale build cache:
  delete the generated files, `dart run build_runner clean`, then
  **Build Runner: Build**.
- **Map shows no tiles on a corporate network** → OSM/CARTO tile hosts
  may be blocked; the rest of the app works regardless.
