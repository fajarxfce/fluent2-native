import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

import '../theme/fluent_icon_type.dart';
import '../theme/fluent_theme.dart';

class FluentText extends StatelessWidget {
  const FluentText(
    this.data, {
    super.key,
    this.type = FluentTextType.primary,
    this.strong = false,
    this.code = false,
    this.underline = false,
    this.style,
    this.maxLines,
    this.color,
  });
  final String data;
  final FluentTextType type;
  final bool strong, code, underline;
  final TextStyle? style;
  final int? maxLines;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final t = theme.tokens;
    final contentStyle = FluentContentStyle.maybeOf(context);
    final foreground =
        color ??
        switch (type) {
          FluentTextType.primary =>
            contentStyle?.color ?? t.colorNeutralForeground1,
          FluentTextType.secondary => t.colorNeutralForeground2,
          FluentTextType.tertiary => t.colorNeutralForeground3,
          FluentTextType.disabled => t.colorNeutralForegroundDisabled,
          FluentTextType.success => t.colorStatusSuccessForeground1,
          FluentTextType.warning => t.colorStatusWarningForeground1,
          FluentTextType.danger => t.colorStatusDangerForeground1,
        };
    final text = Text(
      data,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      style: theme.textStyle
          .merge(contentStyle)
          .copyWith(
            color: foreground,
            fontWeight: strong ? FontWeight.w600 : null,
            fontFamily: code ? 'monospace' : null,
            decoration: underline
                ? TextDecoration.underline
                : TextDecoration.none,
          )
          .merge(style),
    );
    return code
        ? DecoratedBox(
            decoration: BoxDecoration(
              color: t.colorSubtleBackgroundHover,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              child: text,
            ),
          )
        : text;
  }
}

class FluentTitle extends StatelessWidget {
  const FluentTitle(this.data, {super.key, this.level = 3})
    : assert(level >= 1 && level <= 5);
  final String data;
  final int level;

  @override
  Widget build(BuildContext context) {
    final t = FluentTheme.tokensOf(context);
    final sizes = [
      t.fontSizeHero900,
      t.fontSizeHero800,
      t.fontSizeHero700,
      t.fontSizeBase600,
      t.fontSizeBase500,
    ];
    final heights = [
      t.title1LineHeight,
      t.title2LineHeight,
      t.title3LineHeight,
      t.title4LineHeight,
      t.title5LineHeight,
    ];
    return Semantics(
      header: true,
      child: FluentText(
        data,
        strong: true,
        color: t.colorNeutralForeground1,
        style: TextStyle(
          fontSize: sizes[level - 1],
          height: heights[level - 1],
        ),
      ),
    );
  }
}

class FluentIcon extends StatelessWidget {
  const FluentIcon(
    this.icon, {
    super.key,
    this.size = 16,
    this.color,
    this.semanticLabel,
  });
  final FluentIconType icon;
  final double size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticLabel,
    excludeSemantics: semanticLabel == null,
    child: CustomPaint(
      size: Size.square(size),
      painter: _IconPainter(
        icon,
        color ??
            FluentContentStyle.maybeOf(context)?.color ??
            FluentTheme.tokensOf(context).colorNeutralForeground1,
      ),
    ),
  );
}

class _IconPainter extends CustomPainter {
  _IconPainter(this.icon, this.color);
  final FluentIconType icon;
  final Color color;
  static final _paths = <FluentIconType, List<Path>>{};

  @override
  void paint(Canvas canvas, Size size) {
    final paths = _paths.putIfAbsent(
      icon,
      () => icon.paths.map(parseSvgPathData).toList(),
    );
    canvas.save();
    canvas.scale(size.width / icon.viewWidth, size.height / icon.viewHeight);
    canvas.translate(-icon.viewX, -icon.viewY);
    for (final path in paths) {
      canvas.drawPath(path, Paint()..color = color);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_IconPainter oldDelegate) =>
      oldDelegate.icon != icon || oldDelegate.color != color;
}
