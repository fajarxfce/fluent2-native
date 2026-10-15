import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme/fluent_icon_type.dart';
import '../theme/fluent_theme.dart';
import 'button.dart';
import 'typography.dart';

class FluentInput extends StatefulWidget {
  const FluentInput({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.placeholder = '',
    this.label,
    this.status = FluentStatus.none,
    this.errorMessage,
    this.size,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.allowClear = false,
    this.maxLines = 1,
    this.minLines,
    this.prefix,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.clearLabel = 'Clear input',
  });
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged, onSubmitted;
  final String placeholder, clearLabel;
  final String? label, errorMessage;
  final FluentStatus status;
  final FluentSize? size;
  final bool enabled, readOnly, obscureText, allowClear;
  final int? maxLines, minLines;
  final FluentIconType? prefix;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  @override
  State<FluentInput> createState() => _FluentInputState();
}

class _FluentInputState extends State<FluentInput> {
  late TextEditingController _controller;
  late FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _attach();
  }

  void _attach() {
    _controller = widget.controller ?? TextEditingController();
    _focus = widget.focusNode ?? FocusNode();
    _controller.addListener(_refresh);
    _focus.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(FluentInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      final previousValue = _controller.value;
      _controller.removeListener(_refresh);
      if (oldWidget.controller == null) _controller.dispose();
      _controller =
          widget.controller ?? TextEditingController.fromValue(previousValue);
      _controller.addListener(_refresh);
    }
    if (oldWidget.focusNode != widget.focusNode) {
      _focus.removeListener(_refresh);
      if (oldWidget.focusNode == null) _focus.dispose();
      _focus = widget.focusNode ?? FocusNode();
      _focus.addListener(_refresh);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _focus.removeListener(_refresh);
    if (widget.controller == null) _controller.dispose();
    if (widget.focusNode == null) _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final t = theme.tokens;
    final size = widget.size ?? theme.size;
    final accent = switch (widget.status) {
      FluentStatus.error => t.colorStatusDangerBackground3,
      FluentStatus.warning => t.colorStatusWarningBackground3,
      _ => t.colorCompoundBrandStroke,
    };
    final invalid =
        widget.status == FluentStatus.error ||
        widget.status == FluentStatus.warning;
    final border = !widget.enabled
        ? t.colorNeutralStrokeDisabled
        : invalid
        ? accent
        : _focus.hasFocus
        ? t.colorNeutralStroke1Pressed
        : t.colorNeutralStroke1;
    final fontSize = t.fontSizeFor(size);
    return Semantics(
      label: widget.label,
      hint: widget.status == FluentStatus.error ? widget.errorMessage : null,
      child: CustomPaint(
        foregroundPainter: _InputUnderline(
          color: !widget.enabled
              ? t.colorNeutralStrokeDisabled
              : _focus.hasFocus || invalid
              ? accent
              : t.colorNeutralStrokeAccessible,
          width: _focus.hasFocus ? 2 : 1,
          radius: t.borderRadiusMedium,
        ),
        child: AnimatedContainer(
          duration: Duration(
            milliseconds: FluentTheme.motionEnabled(context) ? 100 : 0,
          ),
          constraints: BoxConstraints(
            minHeight: math.max(t.controlSize(size), theme.minimumTouchTarget),
          ),
          decoration: BoxDecoration(
            color: widget.enabled
                ? t.colorNeutralBackground1
                : t.colorNeutralBackgroundDisabled,
            border: Border.all(color: border, width: t.strokeWidthThin),
            borderRadius: BorderRadius.circular(t.radiusFor(size)),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: size == FluentSize.small ? 7 : 11,
          ),
          child: Row(
            children: [
              if (widget.prefix != null) ...[
                FluentIcon(widget.prefix!, color: t.colorNeutralForeground3),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Material(
                  type: MaterialType.transparency,
                  child: TextField(
                    controller: _controller,
                    focusNode: _focus,
                    enabled: widget.enabled,
                    readOnly: widget.readOnly,
                    obscureText: widget.obscureText,
                    maxLines: widget.obscureText ? 1 : widget.maxLines,
                    minLines: widget.minLines,
                    keyboardType: widget.keyboardType,
                    textInputAction: widget.textInputAction,
                    onChanged: widget.onChanged,
                    onSubmitted: widget.onSubmitted,
                    cursorColor: t.colorBrandBackground,
                    style: theme.textStyle.copyWith(
                      fontSize: fontSize,
                      height: t.lineHeightFor(size) / fontSize,
                      color: widget.enabled
                          ? t.colorNeutralForeground1
                          : t.colorNeutralForegroundDisabled,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.placeholder,
                      hintStyle: theme.textStyle.copyWith(
                        color: t.colorNeutralForeground3,
                        fontSize: fontSize,
                        height: t.lineHeightFor(size) / fontSize,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 6),
                    ),
                  ),
                ),
              ),
              if (widget.allowClear &&
                  _controller.text.isNotEmpty &&
                  widget.enabled &&
                  !widget.readOnly)
                FluentButton(
                  type: FluentButtonType.subtle,
                  size: FluentSize.small,
                  semanticLabel: widget.clearLabel,
                  onPressed: () {
                    _controller.clear();
                    widget.onChanged?.call('');
                    _focus.requestFocus();
                  },
                  child: FluentIcon(
                    FluentIconType.close,
                    size: 12,
                    color: t.colorNeutralForeground3,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class FluentField extends StatelessWidget {
  const FluentField({
    super.key,
    required this.label,
    required this.child,
    this.required = false,
    this.help,
    this.status = FluentStatus.none,
  });
  final String label;
  final Widget child;
  final bool required;
  final String? help;
  final FluentStatus status;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Flexible(child: FluentText(label)),
          if (required) const FluentText(' *', type: FluentTextType.danger),
        ],
      ),
      const SizedBox(height: 6),
      child,
      if (help != null) ...[
        const SizedBox(height: 4),
        Semantics(
          liveRegion: status == FluentStatus.error,
          child: FluentText(
            help!,
            type: status == FluentStatus.error
                ? FluentTextType.danger
                : status == FluentStatus.warning
                ? FluentTextType.warning
                : FluentTextType.secondary,
          ),
        ),
      ],
    ],
  );
}

class _InputUnderline extends CustomPainter {
  _InputUnderline({
    required this.color,
    required this.width,
    required this.radius,
  });
  final Color color;
  final double width, radius;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
    );
    canvas.drawLine(
      Offset(0, size.height - width / 2),
      Offset(size.width, size.height - width / 2),
      Paint()
        ..color = color
        ..strokeWidth = width,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_InputUnderline old) =>
      old.color != color || old.width != width || old.radius != radius;
}
