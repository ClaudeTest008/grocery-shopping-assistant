# Development Guide

VS Code workspace guide for the Grocery Shopping Assistant. A new team
member should be running the app on Windows within ten minutes.

Supported targets: **Windows Desktop · Web · Android · iOS**.

## Opening the Project

```bash
git clone https://github.com/ClaudeTest008/grocery-shopping-assistant.git
code grocery-shopping-assistant
```

Install the recommended extensions when VS Code prompts (from
`.vscode/extensions.json`), then press **F5** and pick a launch profile.

The app boots in **demo mode** with no configuration: seeded stores,
products, prices and a mock AI. Real backends connect via `--dart-define`
(see [docs/Deployment.md](docs/Deployment.md)).

## One command to start everything

```bat
dev
```

`dev.cmd` (or `.\scripts\start-dev.ps1`) resolves the Flutter SDK even if
it is not on `PATH`, runs `pub get`, generates code when generated files
are missing, then launches **Windows desktop and Chrome side by side**,
each in its own console so both keep interactive hot reload.

```powershell
.\scripts\start-dev.ps1 -WindowsOnly   # desktop only
.\scripts\start-dev.ps1 -WebOnly       # chrome only
.\scripts\start-dev.ps1 -SkipCodegen
```

The same thing is available inside VS Code: **Run and Debug → "Start
Development (Windows + Chrome)"**, or the default build task
`Ctrl+Shift+B` → **Start Development**.

## Developer scripts

Every script lives in `scripts/` and works from any directory.

| Script | Purpose |
|---|---|
| `.\scripts\start-dev.ps1` | Start the whole local environment (also `dev.cmd`) |
| `.\scripts\verify.ps1` | Format check + analyze + test — everything CI runs |
| `.\scripts\analyze.ps1` | `flutter analyze` |
| `.\scripts\test.ps1` | Tests; `-Coverage`, `-UpdateGoldens`, `-Path <dir>` |
| `.\scripts\codegen.ps1` | build_runner; `-Watch`, `-Clean` |
| `.\scripts\build.ps1` | Release builds; `-Target windows\|web\|apk\|appbundle\|all` |
| `.\scripts\clean.ps1` | `flutter clean` + `pub get`; `-Deep` also clears generated sources and caches |

## Windows Desktop setup

Requirements beyond the Flutter SDK:

- **Visual Studio 2022** (or **Build Tools for Visual Studio 2022**) with
  the **Desktop development with C++** workload, which brings MSVC and
  the Windows 10/11 SDK. Flutter cannot build a Windows app without it.
- Confirm with `flutter doctor` — the line you need is
  `[√] Visual Studio - develop Windows apps`.

No API keys are required: the map uses key-free OpenStreetMap tiles and
the app runs in demo mode by default.

```powershell
flutter config --enable-windows-desktop   # on by default
flutter devices                           # expect "Windows (desktop)"
flutter run -d windows
```

## Running the App

Press **F5** and pick a profile, or use a terminal.

### Windows Desktop

- Profiles: **Flutter: Windows Desktop**, **… (Profile)**, **… (Release)**.
- Terminal: `flutter run -d windows`.
- The window opens centred at 1280×800 and cannot be resized below
  640×560 logical pixels, so the layouts never collapse.

### Web (Chrome)

- **Flutter: Web (Chrome)**, or `flutter run -d chrome`.

### Android Emulator / Connected Device

- Start an emulator (`Ctrl+Shift+P` → "Flutter: Launch Emulator"), then
  **Flutter: Android Emulator**, or `flutter run -d emulator`.
- For a physical device: enable USB debugging, check `flutter devices`,
  then **Flutter: Connected Android Device**.

### iOS Simulator

- macOS only: **Flutter: iOS Simulator** / `flutter run -d ios`. The
  profile is listed on Windows but cannot run there.

## Hot Reload & Hot Restart

Hot reload works on Windows desktop exactly as it does on mobile.

- Saving a Dart file hot-reloads automatically
  (`dart.flutterHotReloadOnSave: always`).
- In a `flutter run` console: `r` = hot reload, `R` = hot restart,
  `q` = quit.
- Debug toolbar: ⚡ reload, ↻ restart.
- Hot reload cannot apply changes to `main()`, `initState` of live
  widgets, enum values, or generated files — hot restart those.
- **Changes to C++ under `windows/runner/` are not hot-reloadable.**
  Stop the app and run again so CMake rebuilds the runner.

## Debugging

- Breakpoints, stepping and the Debug Console work the same on desktop.
- **Widget Inspector**: `Ctrl+Shift+P` → "Flutter: Open Widget Inspector".
- **DevTools** (memory, performance, network): link printed in the Debug
  Console on launch.
- Desktop-only: `flutter run -d windows -v` surfaces CMake and linker
  output when the native side misbehaves.
- To debug the C++ runner itself, open
  `build/windows/x64/grocery_shopping_assistant.sln` in Visual Studio and
  attach to the running process.

## Testing

```powershell
.\scripts\test.ps1                       # or: flutter test
.\scripts\test.ps1 -Coverage             # coverage/lcov.info
.\scripts\test.ps1 -Path test/features/shopping_lists
.\scripts\test.ps1 -UpdateGoldens        # regenerate golden PNGs
flutter test integration_test/app_test.dart   # needs a device
```

`Run | Debug` CodeLens links appear above every `test()` and
`testWidgets()`. Golden tests are tagged `golden` and excluded from CI
because host font rendering differs; regenerate them locally when shared
widgets change.

## Code Analysis & Formatting

- Format-on-save and organize-imports-on-save are configured for Dart.
- `flutter analyze` must stay at **zero issues** (CI enforces).
- `.\scripts\verify.ps1` runs the full CI gate locally.

## Code Generation

Freezed entities and JSON serializers are generated and committed:

```powershell
.\scripts\codegen.ps1            # one-shot
.\scripts\codegen.ps1 -Watch     # regenerate on save
.\scripts\codegen.ps1 -Clean     # nuke generated files first
```

## Building Releases

```powershell
.\scripts\build.ps1 -Target windows     # build\windows\x64\runner\Release\
.\scripts\build.ps1 -Target web         # deployed to GitHub Pages by CI
.\scripts\build.ps1 -Target apk
.\scripts\build.ps1 -Target all
```

### Windows release output

`build\windows\x64\runner\Release\` contains `grocery_shopping_assistant.exe`
plus `flutter_windows.dll`, plugin DLLs and a `data\` folder. **Ship the
whole folder** — the exe alone will not start. The executable carries
proper version metadata (product name "Grocery Shopping Assistant",
version from `pubspec.yaml`).

For a distributable installer, wrap that folder with MSIX, Inno Setup or
WiX. No installer is configured in this repo yet.

## Desktop platform limitations

Several plugins ship no Windows implementation. Rather than crashing with
`MissingPluginException`, the app checks
[`PlatformSupport`](lib/core/platform/platform_support.dart) and degrades
gracefully. Nothing is removed on the platforms that do support it.

| Capability | Windows | Behaviour on Windows |
|---|---|---|
| Barcode scanning (`mobile_scanner`) | ❌ | Screen swaps to a numeric **"Enter barcode"** form; the caller still receives a barcode string |
| Receipt OCR (`google_mlkit_text_recognition`) | ❌ | Picking an image jumps straight to the editable manual form, with an honest explanation |
| Camera capture (`image_picker`) | ❌ | "Take photo" is hidden; "Choose an image file" opens the native Win32 file dialog |
| Payment sheet (`flutter_stripe`) | ❌ | Paywall explains upgrades happen on mobile/web; the account unlocks everywhere |
| Push notifications (`firebase_messaging`) | ❌ | Push is skipped; the in-app notification inbox works normally |
| Phone links (`tel:`) | ⚠️ | No dialler registered → number is copied to the clipboard instead |
| Speech to text | ✅ | Works via `speech_to_text_windows`; enable Speech in Windows Settings → Privacy |
| Location | ✅ | `geolocator_windows` (WinRT). `openLocationSettings()` is unimplemented — unused here |
| Maps, storage, auth, AI, optimizer, charts | ✅ | Fully functional |

Everything else — the basket optimizer, map, lists, pantry, meal planner,
budget charts and the AI assistant — is identical to mobile.

Local data on desktop lives in
`Documents\GroceryShoppingAssistant\` (Hive boxes).

## Useful VS Code Shortcuts

| Shortcut | Action |
|---|---|
| `F5` | Start debugging (launch profile) |
| `Ctrl+F5` | Run without debugging |
| `Shift+F5` | Stop |
| `Ctrl+Shift+P` | Command palette |
| `Ctrl+Shift+B` | Default build task (**Start Development**) |
| `Ctrl+Shift+D` | Run and Debug panel (compound profiles) |
| `Ctrl+.` | Quick fix / refactor (wrap with widget…) |
| `F12` / `Alt+F12` | Go to / peek definition |
| `Ctrl+Shift+F` | Search project (generated files excluded) |
| `` Ctrl+` `` | Toggle terminal |

## Troubleshooting

### Any platform

- **Weird build errors** → `.\scripts\clean.ps1`, or `-Deep` for a full
  reset including generated sources.
- **Analyzer stale** → `Ctrl+Shift+P` → "Dart: Restart Analysis Server".
- **Duplicate classes in `*.freezed.dart`** → stale build cache:
  `.\scripts\codegen.ps1 -Clean`.

### Windows desktop

- **"Unable to find suitable Visual Studio toolchain"** → install the
  *Desktop development with C++* workload, then re-run `flutter doctor`.
- **CMake configures against stale paths after moving the repo** →
  delete `build\windows` (VS Code task **Flutter: Clean Windows Build**).
- **`Nuget.exe not found, trying to download`** during the first build is
  normal: `firebase_core`'s Windows plugin fetches the Firebase C++ SDK.
  It needs network access on the first build only.
- **Native edits appear to do nothing** → C++ is not hot-reloadable; stop
  and relaunch.
- **App starts then exits immediately** → run from a terminal
  (`flutter run -d windows`) to see the Dart stack trace; a bare
  double-click hides console output.
- **Speech input does nothing** → Windows Settings → Privacy & security →
  Speech → enable online speech recognition.
