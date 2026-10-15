import 'package:flutter/material.dart';

import '../theme/fluent_icon_type.dart';
import '../theme/fluent_theme.dart';
import 'typography.dart';

class FluentCard extends StatelessWidget {
  const FluentCard({
    super.key,
    required this.child,
    this.title,
    this.extra,
    this.size,
    this.bordered = true,
  });
  final Widget child;
  final String? title;
  final Widget? extra;
  final FluentSize? size;
  final bool bordered;
  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context), t = theme.tokens;
    final controlSize = size ?? theme.size;
    final padding = switch (controlSize) {
      FluentSize.small => 8.0,
      FluentSize.middle => 12.0,
      FluentSize.large => 16.0,
    };
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: t.colorNeutralBackground1,
        borderRadius: BorderRadius.circular(
          controlSize == FluentSize.large
              ? t.borderRadiusLarge
              : t.borderRadiusMedium,
        ),
        border: bordered ? Border.all(color: t.colorNeutralStrokeAlpha) : null,
        boxShadow: [
          BoxShadow(color: t.colorNeutralShadowAmbient, blurRadius: 2),
          BoxShadow(
            color: t.colorNeutralShadowKey,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null || extra != null) ...[
            Row(
              children: [
                Expanded(
                  child: title == null
                      ? const SizedBox.shrink()
                      : FluentText(title!, strong: true),
                ),
                if (extra != null) ...[const SizedBox(width: 12), extra!],
              ],
            ),
            SizedBox(height: padding),
          ],
          child,
        ],
      ),
    );
  }
}

enum FluentBadgeAppearance { filled, outline }

class FluentBadge extends StatelessWidget {
  const FluentBadge(
    this.text, {
    super.key,
    this.status = FluentStatus.none,
    this.icon,
    this.appearance = FluentBadgeAppearance.filled,
  });
  final String text;
  final FluentStatus status;
  final FluentIconType? icon;
  final FluentBadgeAppearance appearance;
  @override
  Widget build(BuildContext context) {
    final t = FluentTheme.tokensOf(context);
    final color = switch (status) {
      FluentStatus.none => t.colorNeutralBackground5,
      FluentStatus.info => t.colorBrandBackground,
      FluentStatus.success => t.colorPaletteGreenBackground3,
      FluentStatus.warning => t.colorPaletteDarkOrangeBackground3,
      FluentStatus.error => t.colorPaletteRedBackground3,
    };
    final filled = appearance == FluentBadgeAppearance.filled;
    final foreground = status == FluentStatus.none
        ? t.colorNeutralForeground3
        : filled
        ? t.colorNeutralForegroundOnBrand
        : color;
    return Container(
      constraints: const BoxConstraints(minHeight: 20),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: filled ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: filled
              ? Colors.transparent
              : status == FluentStatus.none
              ? t.colorNeutralStrokeAccessible
              : color,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            FluentIcon(icon!, size: 12, color: foreground),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: FluentText(
              text,
              color: foreground,
              strong: true,
              style: TextStyle(
                fontSize: t.fontSizeBase200,
                height: t.lineHeightBase200 / t.fontSizeBase200,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String formatFluentCount(int count, [int overflowCount = 99]) {
  if (count < 0) {
    throw ArgumentError.value(count, 'count', 'must not be negative');
  }
  if (overflowCount <= 0) {
    throw ArgumentError.value(
      overflowCount,
      'overflowCount',
      'must be positive',
    );
  }
  return count > overflowCount ? '$overflowCount+' : '$count';
}

class FluentCounterBadge extends StatelessWidget {
  const FluentCounterBadge({
    super.key,
    required this.child,
    this.count = 0,
    this.dot = false,
    this.showZero = false,
    this.overflowCount = 99,
    this.label,
  });
  final Widget child;
  final int count, overflowCount;
  final bool dot, showZero;
  final String? label;
  @override
  Widget build(BuildContext context) {
    final t = FluentTheme.tokensOf(context);
    final text = formatFluentCount(count, overflowCount);
    final visible = dot || count > 0 || showZero;
    return Semantics(
      label: visible
          ? label ?? (dot ? 'New activity' : '$count notifications')
          : null,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          child,
          if (visible)
            PositionedDirectional(
              end: dot ? -3 : -8,
              top: dot ? -3 : -8,
              child: Container(
                constraints: BoxConstraints(
                  minWidth: dot ? 6 : 20,
                  minHeight: dot ? 6 : 20,
                ),
                padding: EdgeInsets.symmetric(horizontal: dot ? 0 : 5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: t.colorBrandBackground,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: t.colorNeutralBackground1),
                ),
                child: dot
                    ? null
                    : ExcludeSemantics(
                        child: FluentText(
                          text,
                          color: Colors.white,
                          style: const TextStyle(fontSize: 12, height: 1.5),
                        ),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}

class FluentAvatar extends StatelessWidget {
  const FluentAvatar({
    super.key,
    this.text,
    this.size = 40,
    this.square = false,
    this.color,
    this.background,
    this.label,
  });
  final String? text, label;
  final double size;
  final bool square;
  final Color? color, background;
  @override
  Widget build(BuildContext context) {
    final t = FluentTheme.tokensOf(context);
    return Semantics(
      label: label ?? text,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: background ?? t.colorBrandBackground2,
          shape: square ? BoxShape.rectangle : BoxShape.circle,
          borderRadius: square
              ? BorderRadius.circular(t.borderRadiusMedium)
              : null,
        ),
        child: ExcludeSemantics(
          child: text == null
              ? FluentIcon(
                  FluentIconType.user,
                  size: size * 0.5,
                  color: color ?? t.colorBrandForeground1,
                )
              : FluentText(
                  text!,
                  maxLines: 1,
                  color: color ?? t.colorBrandForeground1,
                  style: TextStyle(fontSize: size * 0.4),
                ),
        ),
      ),
    );
  }
}

class FluentDivider extends StatelessWidget {
  const FluentDivider({super.key, this.text});
  final String? text;
  @override
  Widget build(BuildContext context) {
    final line = Expanded(
      child: Container(
        height: 1,
        color: FluentTheme.tokensOf(context).colorNeutralStroke2,
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: LayoutBuilder(
        builder: (context, constraints) => Row(
          children: [
            line,
            if (text != null) ...[
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: (constraints.maxWidth - 32).clamp(
                    0,
                    double.infinity,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FluentText(text!, strong: true, maxLines: 1),
                ),
              ),
              line,
            ],
          ],
        ),
      ),
    );
  }
}

class FluentStack extends StatelessWidget {
  const FluentStack({
    super.key,
    required this.children,
    this.gap = 8,
    this.vertical = false,
  });
  final List<Widget> children;
  final double gap;
  final bool vertical;
  @override
  Widget build(BuildContext context) => vertical
      ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < children.length; index++) ...[
              if (index > 0) SizedBox(height: gap),
              children[index],
            ],
          ],
        )
      : Wrap(
          spacing: gap,
          runSpacing: gap,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: children,
        );
}

class FluentStatistic extends StatelessWidget {
  const FluentStatistic({
    super.key,
    required this.title,
    required this.value,
    this.prefix,
    this.suffix,
  });
  final String title, value;
  final String? prefix, suffix;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      FluentText(title, type: FluentTextType.secondary),
      const SizedBox(height: 4),
      Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (prefix != null) ...[
            FluentText(prefix!, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 4),
          ],
          FluentText(
            value,
            style: const TextStyle(fontSize: 24, height: 1.3333),
          ),
          if (suffix != null) ...[
            const SizedBox(width: 4),
            FluentText(suffix!),
          ],
        ],
      ),
    ],
  );
}
