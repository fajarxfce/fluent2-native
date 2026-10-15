import 'package:flutter/material.dart';

import '../theme/fluent_icon_type.dart';
import '../theme/fluent_theme.dart';
import 'feedback.dart';
import 'pressable.dart';
import 'typography.dart';

class FluentCheckbox extends StatelessWidget {
  const FluentCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
    this.enabled = true,
  });

  /// Null represents Fluent 2's indeterminate state. Activation checks it.
  final bool? value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final t = theme.tokens;
    final active = enabled && onChanged != null;
    return Semantics(
      checked: value == true,
      mixed: value == null,
      enabled: active,
      child: FluentPressable(
        onPressed: active ? () => onChanged!(value != true) : null,
        builder: (context, hovered, pressed, focused) => ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: theme.minimumTouchTarget,
            minWidth: theme.minimumTouchTarget,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: !active
                      ? t.colorNeutralBackgroundDisabled
                      : value != false
                      ? t.colorCompoundBrandBackground
                      : t.colorNeutralBackground1,
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(
                    color: !active
                        ? t.colorNeutralStrokeDisabled
                        : value != false || hovered
                        ? t.colorCompoundBrandStroke
                        : t.colorNeutralStrokeAccessible,
                  ),
                  boxShadow: focused
                      ? [BoxShadow(color: t.colorStrokeFocus2, spreadRadius: 1)]
                      : null,
                ),
                alignment: Alignment.center,
                child: value == false
                    ? null
                    : FluentIcon(
                        value == true
                            ? FluentIconType.check
                            : FluentIconType.minus,
                        size: 14,
                        color: !active
                            ? t.colorNeutralForegroundDisabled
                            : t.colorNeutralForegroundOnBrand,
                      ),
              ),
              if (label != null) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: FluentText(
                    label!,
                    type: active
                        ? FluentTextType.primary
                        : FluentTextType.disabled,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class FluentRadio<T> extends StatelessWidget {
  const FluentRadio({
    super.key,
    required this.value,
    required this.groupValue,
    this.onChanged,
    this.label,
    this.enabled = true,
  });
  final T value;
  final T? groupValue;
  final ValueChanged<T>? onChanged;
  final String? label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final t = theme.tokens;
    final active = enabled && onChanged != null;
    final selected = value == groupValue;
    return Semantics(
      checked: selected,
      inMutuallyExclusiveGroup: true,
      enabled: active,
      child: FluentPressable(
        onPressed: active ? () => onChanged!(value) : null,
        builder: (context, hovered, pressed, focused) => ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: theme.minimumTouchTarget,
            minWidth: theme.minimumTouchTarget,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: active
                      ? t.colorNeutralBackground1
                      : t.colorNeutralBackgroundDisabled,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: active && (selected || hovered)
                        ? t.colorCompoundBrandStroke
                        : active
                        ? t.colorNeutralStrokeAccessible
                        : t.colorNeutralStrokeDisabled,
                  ),
                  boxShadow: focused
                      ? [BoxShadow(color: t.colorStrokeFocus2, spreadRadius: 1)]
                      : null,
                ),
                alignment: Alignment.center,
                child: selected
                    ? Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active
                              ? t.colorBrandBackground
                              : t.colorNeutralForegroundDisabled,
                          shape: BoxShape.circle,
                        ),
                      )
                    : null,
              ),
              if (label != null) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: FluentText(
                    label!,
                    type: active
                        ? FluentTextType.primary
                        : FluentTextType.disabled,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class FluentSwitch extends StatelessWidget {
  const FluentSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.enabled = true,
    this.loading = false,
    this.size,
    this.label,
  });
  final bool value, enabled, loading;
  final ValueChanged<bool>? onChanged;
  final FluentSize? size;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final t = theme.tokens;
    final active = enabled && !loading && onChanged != null;
    final small = (size ?? theme.size) == FluentSize.small;
    final width = small ? 32.0 : 40.0;
    final height = small ? 16.0 : 20.0;
    final background = value
        ? t.colorCompoundBrandBackground
        : Colors.transparent;
    final duration = Duration(
      milliseconds: FluentTheme.motionEnabled(context) ? 150 : 0,
    );
    return Semantics(
      toggled: value,
      enabled: active,
      label: label,
      value: loading ? 'Loading' : null,
      child: FluentPressable(
        onPressed: active ? () => onChanged!(!value) : null,
        builder: (context, hovered, pressed, focused) => ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: theme.minimumTouchTarget,
            minWidth: theme.minimumTouchTarget,
          ),
          child: Align(
            widthFactor: 1,
            heightFactor: 1,
            child: AnimatedContainer(
              width: width,
              height: height,
              duration: duration,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: active
                    ? background
                    : value
                    ? t.colorNeutralBackgroundDisabled
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: !active
                      ? t.colorNeutralStrokeDisabled
                      : value
                      ? Colors.transparent
                      : t.colorNeutralStrokeAccessible,
                ),
                boxShadow: focused
                    ? [BoxShadow(color: t.colorStrokeFocus2, spreadRadius: 1)]
                    : null,
              ),
              child: AnimatedAlign(
                duration: duration,
                curve: Curves.easeInOut,
                alignment: value
                    ? AlignmentDirectional.centerEnd
                    : AlignmentDirectional.centerStart,
                child: Container(
                  width: height - 8,
                  height: height - 8,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: !active
                        ? t.colorNeutralForegroundDisabled
                        : value
                        ? t.colorNeutralForegroundOnBrand
                        : t.colorNeutralStrokeAccessible,
                    shape: BoxShape.circle,
                  ),
                  child: loading
                      ? FluentSpinner(
                          size: height - 8,
                          color: t.colorBrandBackground,
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
