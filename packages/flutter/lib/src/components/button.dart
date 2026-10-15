import 'package:flutter/material.dart';
import '../theme/fluent_theme.dart';
import '../theme/fluent_icon_type.dart';
import 'feedback.dart';
import 'pressable.dart';
import 'typography.dart';

/// The five appearances from Microsoft's Fluent 2 Button recipe.
class FluentButton extends StatelessWidget {
  const FluentButton({
    super.key,
    required this.child,
    this.onPressed,
    this.type = FluentButtonType.secondary,
    this.size,
    this.danger = false,
    this.loading = false,
    this.block = false,
    this.icon,
    this.semanticLabel,
    this.loadingLabel = 'Loading',
    this.focusNode,
    this.autofocus = false,
  });
  final Widget child;
  final VoidCallback? onPressed;
  final FluentButtonType type;
  final FluentSize? size;
  final bool danger, loading, block, autofocus;
  final FluentIconType? icon;
  final String? semanticLabel;
  final String loadingLabel;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context), t = theme.tokens;
    final controlSize = size ?? theme.size;
    final enabled = onPressed != null;
    final plain =
        type == FluentButtonType.subtle || type == FluentButtonType.transparent;
    return Semantics(
      button: true,
      enabled: enabled && !loading,
      label: semanticLabel,
      value: loading ? loadingLabel : null,
      child: FluentPressable(
        onPressed: loading ? null : onPressed,
        focusNode: focusNode,
        autofocus: autofocus,
        builder: (context, hovered, pressed, focused) {
          final accent = danger
              ? (pressed
                    ? t.colorStatusDangerBackground3Pressed
                    : hovered
                    ? t.colorStatusDangerBackground3Hover
                    : t.colorStatusDangerBackground3)
              : (pressed
                    ? t.colorBrandBackgroundPressed
                    : hovered
                    ? t.colorBrandBackgroundHover
                    : t.colorBrandBackground);
          final background = !enabled
              ? (plain ? Colors.transparent : t.colorNeutralBackgroundDisabled)
              : type == FluentButtonType.primary
              ? accent
              : type == FluentButtonType.outline ||
                    type == FluentButtonType.transparent
              ? Colors.transparent
              : type == FluentButtonType.subtle
              ? (pressed
                    ? t.colorSubtleBackgroundPressed
                    : hovered
                    ? t.colorSubtleBackgroundHover
                    : Colors.transparent)
              : pressed
              ? t.colorNeutralBackground1Pressed
              : hovered
              ? t.colorNeutralBackground1Hover
              : t.colorNeutralBackground1;
          final foreground = !enabled
              ? t.colorNeutralForegroundDisabled
              : type == FluentButtonType.primary
              ? t.colorNeutralForegroundOnBrand
              : danger
              ? t.colorStatusDangerForeground1
              : type == FluentButtonType.transparent && pressed
              ? t.colorNeutralForeground2BrandPressed
              : type == FluentButtonType.transparent && hovered
              ? t.colorNeutralForeground2BrandHover
              : plain
              ? t.colorNeutralForeground2
              : t.colorNeutralForeground1;
          final border = plain || type == FluentButtonType.primary
              ? Colors.transparent
              : !enabled
              ? t.colorNeutralStrokeDisabled
              : pressed
              ? t.colorNeutralStroke1Pressed
              : hovered
              ? t.colorNeutralStroke1Hover
              : t.colorNeutralStroke1;
          final style = theme.textStyle.copyWith(
            color: foreground,
            fontSize: t.fontSizeFor(controlSize),
            height: t.lineHeightFor(controlSize) / t.fontSizeFor(controlSize),
            fontWeight: FontWeight.w600,
          );
          return ConstrainedBox(
            constraints: BoxConstraints(minHeight: theme.minimumTouchTarget),
            child: Align(
              widthFactor: block ? null : 1,
              heightFactor: 1,
              child: AnimatedContainer(
                duration: Duration(
                  milliseconds: FluentTheme.motionEnabled(context)
                      ? t.durationFaster.round()
                      : 0,
                ),
                constraints: BoxConstraints(
                  minHeight: t.controlSize(controlSize),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: controlSize == FluentSize.small ? 8 : 12,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(t.borderRadiusMedium),
                  border: Border.all(color: border),
                ),
                foregroundDecoration: focused
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          t.borderRadiusMedium,
                        ),
                        border: Border.all(
                          color: t.colorStrokeFocus2,
                          width: 2,
                        ),
                      )
                    : null,
                child: FluentContentStyle(
                  style: style,
                  child: DefaultTextStyle(
                    style: style,
                    child: Row(
                      mainAxisSize: block ? MainAxisSize.max : MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (loading) ...[
                          FluentSpinner(
                            size: 16,
                            color: foreground,
                            label: loadingLabel,
                          ),
                          const SizedBox(width: 6),
                        ] else if (icon != null) ...[
                          FluentIcon(
                            icon!,
                            size: controlSize == FluentSize.large ? 24 : 20,
                            color: foreground,
                          ),
                          const SizedBox(width: 6),
                        ],
                        Flexible(child: child),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
