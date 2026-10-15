# Verification

Local validation uses Linux, JDK 21 (JVM target 17), Android SDK 36, Kotlin 2.2.21 / Compose 1.9.3, Flutter 3.47.5 / Dart 3.13.4, and the checked-in dependency locks.

| Check | Result |
| --- | --- |
| Official theme/icon snapshots and both generators | Passed |
| Compose contracts and desktop UI interactions | 13 tests passed (including icon geometry) |
| Flutter component interactions | 12 tests passed |
| Flutter catalog, 390/1280 widths, all four themes, compact size and search | 2 tests passed |
| Flutter library/catalog analysis | Passed after lint fixes |
| Compose Android and Wasm production distribution | Built |
| Flutter optimized split Android APKs and web production distribution | Built |
| Android 7 / API 24 emulator, Compose | Launch, Web/Teams theme changes, dropdown, async dialog and Accordion passed; no app runtime crash |
| Android 7 / API 24 emulator, Flutter | Launch, Web/Teams themes, dropdown, async dialog and Accordion passed; final normalized-path APK being rechecked |
| Samsung SM_A725F / Android 16 | Compose installed/launched; final APK installation checks in progress |

Behavior tests cover disabled/loading activation, input clearing and controller ownership, read-only editing, mixed checkbox state, disabled-option keyboard traversal, dark-theme popup propagation, async confirmation/retry, accordion navigation and expansion, multiline input, and breadcrumb navigation.

The catalog tests select all four real themes, separately change compact density, and exercise search. Browser build checks are compilation checks; interactive browser testing is not claimed. iOS, macOS, Windows, and physical screen-reader testing require their corresponding environments.

Android APKs and build directories are excluded from Git. CI uploads APKs, browser distributions, and Compose test reports. The Flutter sample release configuration uses the development key; it is suitable for a local demo, not a store signing configuration.

## Reproduce Android smoke checks

The helper uses a 720 × 1280 emulator at 280 dpi. It checks native interactions and samples the four hollow tile interiors in the official Apps icon; this catches the relative-contour rendering difference observed with Compose on Android API 24. Original SVG source paths remain in the snapshot alongside normalized paths.

```bash
python3 -m venv .venv
.venv/bin/pip install -r tools/requirements.txt
.venv/bin/python tools/android_smoke.py compose --serial YOUR_EMULATOR
.venv/bin/python tools/android_smoke.py flutter --serial YOUR_EMULATOR
```

Install the relevant APK before each command. The helper restarts only its target catalog package and writes ignored screenshots/UI dumps to `artifacts/`. Physical-device verification covers install and launch; interaction checks run on the emulator.
