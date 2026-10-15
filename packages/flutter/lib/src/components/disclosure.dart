import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/fluent_theme.dart';
import '../theme/fluent_icon_type.dart';
import 'button.dart';
import 'input.dart';
import 'navigation.dart';
import 'typography.dart';

class FluentTextarea extends StatelessWidget {
  const FluentTextarea({
    super.key,
    this.controller,
    this.onChanged,
    this.label,
    this.placeholder = '',
    this.rows = 3,
    this.enabled = true,
    this.readOnly = false,
    this.status = FluentStatus.none,
    this.errorMessage,
    this.focusNode,
  }) : assert(rows > 0);
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? label, errorMessage;
  final String placeholder;
  final int rows;
  final bool enabled, readOnly;
  final FluentStatus status;
  final FocusNode? focusNode;
  @override
  Widget build(BuildContext context) => FluentInput(
    controller: controller,
    onChanged: onChanged,
    label: label,
    placeholder: placeholder,
    maxLines: null,
    minLines: rows,
    enabled: enabled,
    readOnly: readOnly,
    status: status,
    errorMessage: errorMessage,
    focusNode: focusNode,
    keyboardType: TextInputType.multiline,
  );
}

/// Callback-based navigation: the host application owns the destination.
class FluentLink extends StatelessWidget {
  const FluentLink(this.text, {super.key, this.onPressed});
  final String text;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    final t = FluentTheme.tokensOf(context);
    return Semantics(
      link: true,
      child: FluentButton(
        onPressed: onPressed,
        type: FluentButtonType.transparent,
        child: FluentText(
          text,
          color: onPressed == null
              ? t.colorNeutralForegroundDisabled
              : t.colorBrandForegroundLink,
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}

@immutable
class FluentAccordionItem {
  const FluentAccordionItem({
    required this.id,
    required this.title,
    required this.child,
    this.enabled = true,
  });
  final String id, title;
  final Widget child;
  final bool enabled;
}

class FluentAccordion extends StatefulWidget {
  const FluentAccordion({
    super.key,
    required this.items,
    required this.expanded,
    required this.onChanged,
    this.multiple = false,
  });
  final List<FluentAccordionItem> items;
  final Set<String> expanded;
  final ValueChanged<Set<String>> onChanged;
  final bool multiple;
  @override
  State<FluentAccordion> createState() => _FluentAccordionState();
}

class _FluentAccordionState extends State<FluentAccordion> {
  final _focus = <String, FocusNode>{};
  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(FluentAccordion old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    final ids = widget.items.map((item) => item.id).toSet();
    if (ids.length != widget.items.length) {
      throw ArgumentError('Accordion IDs must be unique');
    }
    for (final id in _focus.keys.toList()) {
      if (!ids.contains(id)) _focus.remove(id)!.dispose();
    }
    for (final id in ids) {
      _focus.putIfAbsent(id, () => FocusNode());
    }
  }

  @override
  void dispose() {
    for (final node in _focus.values) {
      node.dispose();
    }
    super.dispose();
  }

  KeyEventResult _key(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final current = widget.items.indexWhere(
      (item) => _focus[item.id]!.hasPrimaryFocus,
    );
    if (current < 0) return KeyEventResult.ignored;
    final options = widget.items
        .map((item) => FluentOption(item.id, item.title, enabled: item.enabled))
        .toList();
    final next = switch (event.logicalKey) {
      LogicalKeyboardKey.arrowDown => nextEnabledFluentOption(
        options,
        current,
        1,
      ),
      LogicalKeyboardKey.arrowUp => nextEnabledFluentOption(
        options,
        current,
        -1,
      ),
      LogicalKeyboardKey.home => widget.items.indexWhere(
        (item) => item.enabled,
      ),
      LogicalKeyboardKey.end => widget.items.lastIndexWhere(
        (item) => item.enabled,
      ),
      _ => null,
    };
    if (next == null || next < 0) return KeyEventResult.ignored;
    _focus[widget.items[next].id]!.requestFocus();
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) => Focus(
    canRequestFocus: false,
    onKeyEvent: _key,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in widget.items) ...[
          Semantics(
            header: true,
            expanded: widget.expanded.contains(item.id),
            child: FluentButton(
              block: true,
              focusNode: _focus[item.id],
              type: FluentButtonType.subtle,
              onPressed: !item.enabled
                  ? null
                  : () {
                      final open = widget.expanded.contains(item.id);
                      widget.onChanged(
                        open
                            ? (Set<String>.of(widget.expanded)..remove(item.id))
                            : widget.multiple
                            ? {...widget.expanded, item.id}
                            : {item.id},
                      );
                    },
              child: Row(
                children: [
                  FluentIcon(
                    widget.expanded.contains(item.id)
                        ? FluentIconType.down
                        : FluentIconType.right,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: FluentText(item.title)),
                ],
              ),
            ),
          ),
          if (widget.expanded.contains(item.id))
            Padding(
              padding: const EdgeInsetsDirectional.only(
                start: 40,
                end: 12,
                bottom: 12,
              ),
              child: item.child,
            ),
        ],
      ],
    ),
  );
}

@immutable
class FluentBreadcrumbItem {
  const FluentBreadcrumbItem(this.id, this.label);
  final String id, label;
}

class FluentBreadcrumb extends StatelessWidget {
  const FluentBreadcrumb({
    super.key,
    required this.items,
    required this.onNavigate,
  });
  final List<FluentBreadcrumbItem> items;
  final ValueChanged<String> onNavigate;
  @override
  Widget build(BuildContext context) {
    if (items.map((item) => item.id).toSet().length != items.length) {
      throw ArgumentError('Breadcrumb IDs must be unique');
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            if (index > 0)
              FluentIcon(
                FluentIconType.right,
                size: 12,
                color: FluentTheme.tokensOf(context).colorNeutralForeground3,
              ),
            if (index == items.length - 1)
              Semantics(
                value: 'Current page',
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: FluentText(items[index].label, strong: true),
                ),
              )
            else
              FluentLink(
                items[index].label,
                onPressed: () => onNavigate(items[index].id),
              ),
          ],
        ],
      ),
    );
  }
}
