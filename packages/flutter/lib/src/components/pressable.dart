import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef FluentPressableBuilder =
    Widget Function(
      BuildContext context,
      bool hovered,
      bool pressed,
      bool focused,
    );

/// Shared keyboard, pointer and focus handling. Each component supplies its own
/// semantic role, value, label and visual treatment.
class FluentPressable extends StatefulWidget {
  const FluentPressable({
    super.key,
    required this.builder,
    this.onPressed,
    this.focusNode,
    this.autofocus = false,
  });
  final VoidCallback? onPressed;
  final FluentPressableBuilder builder;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  State<FluentPressable> createState() => _FluentPressableState();
}

class _FluentPressableState extends State<FluentPressable> {
  bool hovered = false, pressed = false, focused = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    return FocusableActionDetector(
      enabled: enabled,
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
      mouseCursor: enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
      },
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onPressed?.call();
            return null;
          },
        ),
      },
      onShowHoverHighlight: (value) => setState(() => hovered = value),
      onShowFocusHighlight: (value) => setState(() => focused = value),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onPressed,
        onTapDown: enabled ? (_) => setState(() => pressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => pressed = false) : null,
        onTapCancel: () => setState(() => pressed = false),
        child: widget.builder(
          context,
          enabled && hovered,
          enabled && pressed,
          enabled && focused,
        ),
      ),
    );
  }
}
