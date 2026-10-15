# Verification — 15 October 2026

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
| Android 7 / API 24 emulator, Compose | Launch, official icon geometry, Web/Teams theme changes, dropdown, async dialog and Accordion passed; no app runtime crash |
| Android 7 / API 24 emulator, Flutter | Launch, official icon geometry, Web/Teams themes, dropdown, async dialog and Accordion passed; no app runtime crash |
| Samsung SM_A725F / Android 16 | Final Compose and Flutter APKs installed over ADB and launched successfully |

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

## Final Android artifacts

| APK | SHA-256 |
| --- | --- |
| Compose debug | `c72b50d98a4530e4b9060f0a9878524401c7d306998dc6e201a49f456a68a4bf` |
| Flutter arm64 release | `8a09e356440f16bb9201b5a92a22217b91c953a00315f2ffd6a7541f9f7e8609` |
| Flutter x86_64 release | `22169584f19072cb82f0c18673aa973c1c4d86d62077946e937b35a058b15a47` |

The Flutter x86_64 APK was tested on the emulator; the arm64 APK was installed on the physical phone. These are hashes of the locally verified artifacts; CI rebuilds may differ because development signing keys and build environments differ.
