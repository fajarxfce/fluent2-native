# Component coverage — 0.1.0

Both libraries implement the same 24 core families. APIs are idiomatic Kotlin/Dart; they are not React prop bindings. The catalog groups related families into 19 interactive previews.

| Family | Implemented | Deliberate limits in this version |
| --- | --- | --- |
| Button | Primary/secondary/outline/subtle/transparent; three sizes; icon, loading, disabled, keyboard/focus | SplitButton, MenuButton, compound/toggle variants absent; danger is a native extension |
| Typography | Body, captions through styles, five title levels, semantic/status text, code/underline | System font fallback; not every named React typography wrapper |
| Icon | 26 official regular SVG vectors | No full icon catalog, filled/regular hover substitution, or automatic RTL mirroring |
| Input | Controlled/native editing, password, prefix, clear, error/warning, sizes | Outline appearance only; clear is an optional native convenience |
| Field | Label, required marker, help/validation text | Caller supplies input label, validation, and form state |
| Textarea | Multiline editor, rows, external controller, read-only, validation | No browser resize handle |
| Checkbox | Checked, unchecked, mixed, disabled, semantics | Standard 16-pixel visual size |
| Radio | Controlled exclusive selection, disabled, native semantics | Host composes group layout |
| Switch | On/off, disabled/loading, two track sizes, directional thumb | Loading is a native extension |
| Dropdown | Single value, disabled options, focus/keyboard popup, overlay theme | No free typing, filtering, multiselect, or virtual lists |
| TabList | Controlled tabs and content, disabled tabs, arrows/Home/End | Horizontal only; no browser URL integration |
| Card | Fluent spacing/radius/depth, title/extra/content slots | No selectable/interactable/media-preview card variants |
| Badge | Filled/outline, neutral/brand/status, optional icon | No tint/ghost, all palette choices, or all size variants |
| CounterBadge | Count/overflow, zero policy, accessible label, dot, anchored composition | Anchoring/dot are native helpers; default brand fill |
| Avatar | Initials/fallback icon, circle/square, custom size/colors | No image loading, presence or avatar group |
| Divider | Horizontal, optional text | Vertical variant absent |
| MessageBar | Info/success/warning/error, title/description/icon, dismiss, live region | No action slot or stacking manager |
| ProgressBar | Determinate/clamped values, success/error/warning | Circular indicator and percent text are native extensions; no indeterminate bar |
| Spinner | Arc animation, semantic loading label, reduced motion | Native constant-sweep animation; not CSS keyframe identity |
| Skeleton | Rows, avatar, loading semantics | Static placeholders; no shimmer |
| Dialog | Modal title/content/actions, controlled Compose state, Flutter async retry and busy guard | Single confirmation pattern; not every dialog slot/type |
| Accordion | Controlled expansion, single/multiple, disabled, keyboard headers | No nested focus behavior beyond native traversal |
| Breadcrumb | Callback navigation for ancestors, static current page | No overflow-collapse/menu strategy |
| Link | Underlined callback action, enabled/disabled | Host owns navigation; not an HTML anchor/URL object |

`FluentStack`, `FluentToggleGroup`, `FluentStatistic`, and `FluentEmptyState` are native composition helpers and are **not included** in the 24-family Fluent parity count. Circular progress, count anchoring, input clear, and busy states are likewise convenience APIs.

Future work includes DataGrid/Table, Tree, DatePicker/Calendar, Combobox, Menu, Toolbar, Toast, Tooltip/Popover, full variant coverage, more icons, localization resources, and assistive-technology validation. The test suite covers meaningful interactions and regressions rather than asserting every possible visual combination.
