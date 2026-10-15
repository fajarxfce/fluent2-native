# Architecture

## Official source, native output

The lockfile in `tools/tokens` pins Microsoft Fluent packages. `sync.mjs` reads the actual `webLightTheme`, `webDarkTheme`, `teamsLightTheme`, and `teamsDarkTheme` exports from `@fluentui/react-theme`. It selects 120 colors and all 69 numeric theme tokens. Font stacks, curves, and shadow recipes are also preserved as reference metadata in `tokens/fluent2.json`.

Colors use **#AARRGGBB** after a single eight-bit alpha conversion. CSS lengths become logical pixels; Compose fonts use `sp`. Line-height tokens retain their absolute upstream values; Flutter converts those values to font-size ratios when creating `TextStyle`. Duration tokens are milliseconds, and weights are unitless.

`sync-icons.mjs` renders the 26 selected regular icon exports at build time and extracts their original SVG paths/view boxes. The snapshot retains those source paths alongside absolute, expanded cubic paths generated with pinned `svgpath` 2.6.0. This avoids incorrect relative-contour rendering observed on Android API 24 while preserving the original icon geometry. The Python generators produce Kotlin and Dart source. All generated outputs are checked in, so consuming the libraries needs neither React, Node, JSON parsing, nor network access at runtime. Exporters and generators have strict `--check` modes.

Compose stores color and numeric values in separate immutable groups to keep JVM method signatures within parameter limits. Convenience getters on `FluentTokens` expose the original Microsoft token names. Flutter exposes an immutable token class with `copyWith`.

## Component recipes

Button implements Fluent's primary, secondary, outline, subtle, and transparent appearances; its neutral hover/pressed states do not change into brand borders. Text uses the Fluent 14/20 body scale and semibold action labels. Input uses the neutral accessible bottom stroke and the thicker compound-brand focus stroke. Switch uses outlined neutral and filled brand tracks. TabList uses an inset selection indicator, Card uses Fluent spacing/depth, and Spinner uses an arc.

Component sizes are recipe values, not invented global Microsoft tokens: 24/32/40 logical pixels for controls, with a 44-pixel minimum interaction target by default. Compact density selects small controls without changing the chosen Web/Teams theme. Visual sizes can grow with system font scaling. The catalogs use smaller interaction targets on desktop-sized windows.

Platform rendering makes shadows, animation interpolation, native text selection, and font metrics differ from browser CSS. The supplied snapshots preserve exact source colors/dimensions; the implementation does not claim pixel identity for every native rasterization or Fluent React variant. System sans-serif fonts are used rather than redistributing Segoe.

## Compose Multiplatform

The complete component implementation lives in `commonMain`, using Compose Foundation for text editing, layout, focus, semantics, popups, and dialogs. It has no Material UI dependency. Targets are Android, JVM desktop, iOS arm64/simulator arm64, and Wasm/JS. The catalog provides Android, desktop, and Wasm entry points. There is no separate Swift framework or Xcode catalog in this repository.

`FluentTheme` provides tokens, default size, motion, and touch-target configuration. Selection, disclosure, and dialog visibility are caller controlled. The dialog caller owns coroutine scope, async work, loading, and errors. The example handles these explicitly.

## Flutter

An `InheritedTheme` propagates `FluentThemeData` into menus/dialog routes. `FluentContentStyle` preserves compound component text styling across Flutter platform defaults. The shared pressable handles pointer, keyboard, and focus interaction. Native text editing, popup-menu navigation, and dialog routes use Flutter services with Fluent visuals.

Inputs dispose only internally created controllers/focus nodes. External controllers survive replacement and unmounting. `showFluentDialog` prevents duplicate async confirmation and dismissal while busy; errors remain visible and allow a retry.

## Interaction and accessibility

Controls expose native semantic states and accept labels for icon-only actions. Arrow/Home/End selection navigation skips disabled options; Accordion handles Up/Down/Home/End header focus. Breadcrumb leaves the final page static. Link navigation is callback-based, so the application owns URLs/routing. Directional layouts support RTL, though automatic icon mirroring is not currently implemented. Reduced motion stops spinners and transition animations; applications can disable Compose motion explicitly and Flutter additionally reads the platform preference.

This is a tested starting implementation, not an assistive-technology certification. See the coverage matrix for component-specific omissions and the verification document for actual tested platforms.
