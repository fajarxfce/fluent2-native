import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/fluent_icon_type.dart';
import '../theme/fluent_theme.dart';
import 'button.dart';
import 'pressable.dart';
import 'typography.dart';

@immutable
class FluentOption<T extends Object> {
  const FluentOption(this.value, this.label, {this.enabled = true});
  final T value;
  final String label;
  final bool enabled;
}

void _validateOptions<T extends Object>(List<FluentOption<T>> options) {
  if (options.map((option) => option.value).toSet().length != options.length) {
    throw ArgumentError('Option values must be unique');
  }
}

int? nextEnabledFluentOption<T extends Object>(
  List<FluentOption<T>> options,
  int current,
  int direction,
) {
  for (var step = 1; step <= options.length; step++) {
    final index = (current + direction * step) % options.length;
    if (options[index].enabled) return index;
  }
  return null;
}

class FluentDropdown<T extends Object> extends StatefulWidget {
  const FluentDropdown({
    super.key,
    required this.options,
    this.value,
    this.onChanged,
    this.placeholder = 'Select an option',
    this.label,
    this.enabled = true,
    this.size,
  });
  final List<FluentOption<T>> options;
  final T? value;
  final ValueChanged<T>? onChanged;
  final String placeholder;
  final String? label;
  final bool enabled;
  final FluentSize? size;
  @override
  State<FluentDropdown<T>> createState() => _FluentSelectState<T>();
}

class _FluentSelectState<T extends Object> extends State<FluentDropdown<T>> {
  final _anchor = GlobalKey();
  bool _open = false;

  Future<void> _showMenu() async {
    final theme = FluentTheme.of(context);
    final t = theme.tokens;
    final anchor = _anchor.currentContext!.findRenderObject()! as RenderBox;
    final overlay =
        Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
    final offset = anchor.localToGlobal(
      Offset(0, anchor.size.height),
      ancestor: overlay,
    );
    setState(() => _open = true);
    final result = await showMenu<FluentOption<T>>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(offset.dx, offset.dy, anchor.size.width, 0),
        Offset.zero & overlay.size,
      ),
      constraints: BoxConstraints(
        minWidth: math.min(anchor.size.width, overlay.size.width - 32),
        maxWidth: math.min(
          math.max(anchor.size.width, 160),
          overlay.size.width - 32,
        ),
      ),
      color: t.colorNeutralBackground1,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(t.borderRadiusMedium),
      ),
      menuPadding: const EdgeInsets.all(4),
      requestFocus: true,
      items: widget.options
          .map(
            (option) => PopupMenuItem<FluentOption<T>>(
              value: option,
              enabled: option.enabled,
              height: math.max(32, theme.minimumTouchTarget),
              padding: EdgeInsets.zero,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: option.value == widget.value
                      ? t.colorNeutralBackground1Selected
                      : null,
                  borderRadius: BorderRadius.circular(t.borderRadiusMedium),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: FluentText(
                        option.label,
                        strong: option.value == widget.value,
                        type: option.enabled
                            ? FluentTextType.primary
                            : FluentTextType.disabled,
                      ),
                    ),
                    if (option.value == widget.value)
                      FluentIcon(
                        FluentIconType.check,
                        size: 14,
                        color: t.colorBrandBackground,
                      ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
    if (!mounted) return;
    setState(() => _open = false);
    if (result != null &&
        widget.enabled &&
        widget.options.any(
          (option) => option.value == result.value && option.enabled,
        )) {
      widget.onChanged?.call(result.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    _validateOptions(widget.options);
    final selected = widget.options
        .where((option) => option.value == widget.value)
        .firstOrNull;
    final active =
        widget.enabled &&
        widget.onChanged != null &&
        widget.options.any((option) => option.enabled);
    return FluentButton(
      key: _anchor,
      onPressed: active && !_open ? _showMenu : null,
      block: true,
      size: widget.size,
      semanticLabel: widget.label,
      child: Row(
        children: [
          Expanded(
            child: FluentText(
              selected?.label ?? widget.placeholder,
              type: selected == null
                  ? FluentTextType.tertiary
                  : FluentTextType.primary,
            ),
          ),
          const SizedBox(width: 8),
          FluentIcon(
            FluentIconType.down,
            size: 12,
            color: FluentTheme.tokensOf(context).colorNeutralForeground3,
          ),
        ],
      ),
    );
  }
}

class FluentToggleGroup<T extends Object> extends StatelessWidget {
  const FluentToggleGroup({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.block = false,
  });
  final T value;
  final List<FluentOption<T>> options;
  final ValueChanged<T> onChanged;
  final bool block;
  @override
  Widget build(BuildContext context) => _FluentOptionBar(
    value: value,
    options: options,
    onChanged: onChanged,
    segmented: true,
    block: block,
  );
}

class FluentTabList<T extends Object> extends StatelessWidget {
  const FluentTabList({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    required this.builder,
  });
  final T value;
  final List<FluentOption<T>> options;
  final ValueChanged<T> onChanged;
  final Widget Function(BuildContext context, T value) builder;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _FluentOptionBar(
        value: value,
        options: options,
        onChanged: onChanged,
        segmented: false,
        block: false,
      ),
      const SizedBox(height: 16),
      builder(context, value),
    ],
  );
}

class _FluentOptionBar<T extends Object> extends StatefulWidget {
  const _FluentOptionBar({
    required this.value,
    required this.options,
    required this.onChanged,
    required this.segmented,
    required this.block,
  });
  final T value;
  final List<FluentOption<T>> options;
  final ValueChanged<T> onChanged;
  final bool segmented, block;
  @override
  State<_FluentOptionBar<T>> createState() => _FluentOptionBarState<T>();
}

class _FluentOptionBarState<T extends Object>
    extends State<_FluentOptionBar<T>> {
  final _nodes = <FocusNode>[];
  @override
  void initState() {
    super.initState();
    _resizeNodes();
  }

  @override
  void didUpdateWidget(_FluentOptionBar<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _resizeNodes();
  }

  void _resizeNodes() {
    while (_nodes.length > widget.options.length) {
      _nodes.removeLast().dispose();
    }
    while (_nodes.length < widget.options.length) {
      _nodes.add(FocusNode());
    }
  }

  @override
  void dispose() {
    for (final node in _nodes) {
      node.dispose();
    }
    super.dispose();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final current = _nodes.indexWhere((node) => node.hasFocus);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    int? next;
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      next = nextEnabledFluentOption(widget.options, current, rtl ? -1 : 1);
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      next = nextEnabledFluentOption(widget.options, current, rtl ? 1 : -1);
    }
    if (event.logicalKey == LogicalKeyboardKey.home) {
      next = widget.options.indexWhere((option) => option.enabled);
    }
    if (event.logicalKey == LogicalKeyboardKey.end) {
      next = widget.options.lastIndexWhere((option) => option.enabled);
    }
    if (next == null || next < 0) return KeyEventResult.ignored;
    _nodes[next].requestFocus();
    widget.onChanged(widget.options[next].value);
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    _validateOptions(widget.options);
    final theme = FluentTheme.of(context);
    final t = theme.tokens;
    Widget item(int index) {
      final option = widget.options[index];
      final selected = option.value == widget.value;
      return Semantics(
        selected: selected,
        button: true,
        enabled: option.enabled,
        inMutuallyExclusiveGroup: true,
        child: FluentPressable(
          focusNode: _nodes[index],
          onPressed: option.enabled
              ? () => widget.onChanged(option.value)
              : null,
          builder: (context, hovered, pressed, focused) => Container(
            constraints: BoxConstraints(
              minHeight: math.max(
                widget.segmented ? 28 : 36,
                theme.minimumTouchTarget,
              ),
            ),
            alignment: widget.block ? Alignment.center : null,
            padding: EdgeInsets.symmetric(
              horizontal: widget.segmented ? 12 : 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: widget.segmented && selected
                  ? t.colorNeutralBackground1
                  : hovered
                  ? t.colorSubtleBackgroundHover
                  : null,
              borderRadius: widget.segmented
                  ? BorderRadius.circular(t.borderRadiusMedium)
                  : null,
              boxShadow: focused
                  ? [BoxShadow(color: t.colorStrokeFocus2, spreadRadius: 1)]
                  : null,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 2,
                    color: !widget.segmented && selected
                        ? t.colorCompoundBrandStroke
                        : Colors.transparent,
                  ),
                ),
              ),
              child: FluentText(
                option.label,
                strong: selected && !widget.segmented,
                color: !option.enabled
                    ? t.colorNeutralForegroundDisabled
                    : selected && !widget.segmented
                    ? t.colorCompoundBrandForeground1
                    : t.colorNeutralForeground1,
              ),
            ),
          ),
        ),
      );
    }

    final row = Row(
      mainAxisSize: widget.block ? MainAxisSize.max : MainAxisSize.min,
      children: [
        for (var index = 0; index < widget.options.length; index++)
          widget.block ? Expanded(child: item(index)) : item(index),
      ],
    );
    return Focus(
      onKeyEvent: _onKey,
      canRequestFocus: false,
      child: Container(
        padding: widget.segmented ? const EdgeInsets.all(2) : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: widget.segmented ? t.colorNeutralBackground3 : null,
          borderRadius: widget.segmented
              ? BorderRadius.circular(t.borderRadiusMedium)
              : null,
        ),
        child: widget.block
            ? row
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: row,
              ),
      ),
    );
  }
}
