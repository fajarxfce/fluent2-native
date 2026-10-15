import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme/fluent_icon_type.dart';
import '../theme/fluent_theme.dart';
import 'button.dart';
import 'typography.dart';

class FluentSpinner extends StatefulWidget {
  const FluentSpinner({
    super.key,
    this.size = 20,
    this.color,
    this.label = 'Loading',
  });
  final double size;
  final Color? color;
  final String label;
  @override
  State<FluentSpinner> createState() => _FluentSpinnerState();
}

class _FluentSpinnerState extends State<FluentSpinner>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (FluentTheme.motionEnabled(context)) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = FluentTheme.tokensOf(context);
    return Semantics(
      label: widget.label,
      child: RotationTransition(
        turns: _controller,
        child: CustomPaint(
          size: Size.square(widget.size),
          painter: _SpinnerArc(
            widget.color ?? t.colorBrandBackground,
            t.colorNeutralStroke2,
          ),
        ),
      ),
    );
  }
}

class _SpinnerArc extends CustomPainter {
  _SpinnerArc(this.color, this.track);
  final Color color, track;
  @override
  void paint(Canvas canvas, Size size) {
    final width = math.max(2.0, size.shortestSide / 10);
    final rect = (Offset.zero & size).deflate(width / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    canvas.drawArc(rect, 0, math.pi * 2, false, paint..color = track);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 1.5,
      false,
      paint
        ..color = color
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_SpinnerArc old) =>
      old.color != color || old.track != track;
}

class FluentMessageBar extends StatelessWidget {
  const FluentMessageBar({
    super.key,
    required this.message,
    this.description,
    this.type = FluentStatus.info,
    this.showIcon = true,
    this.onClose,
    this.closeLabel = 'Dismiss message',
  });
  final String message;
  final String? description;
  final FluentStatus type;
  final bool showIcon;
  final VoidCallback? onClose;
  final String closeLabel;

  @override
  Widget build(BuildContext context) {
    final t = FluentTheme.tokensOf(context);
    final colors = t.statusColors(type);
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colors.background,
          border: Border.all(color: colors.border),
          borderRadius: BorderRadius.circular(t.borderRadiusMedium),
        ),
        child: Row(
          crossAxisAlignment: description == null
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            if (showIcon) ...[
              Padding(
                padding: EdgeInsets.only(top: description == null ? 0 : 3),
                child: FluentIcon(type.icon, size: 20, color: colors.color),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FluentText(message, strong: description != null),
                  if (description != null) ...[
                    const SizedBox(height: 4),
                    FluentText(description!),
                  ],
                ],
              ),
            ),
            if (onClose != null)
              FluentButton(
                type: FluentButtonType.subtle,
                size: FluentSize.small,
                onPressed: onClose,
                semanticLabel: closeLabel,
                child: const FluentIcon(FluentIconType.close, size: 12),
              ),
          ],
        ),
      ),
    );
  }
}

enum FluentProgressType { line, circle }

double normalizeFluentPercent(double value) {
  if (!value.isFinite) {
    throw ArgumentError.value(value, 'percent', 'must be finite');
  }
  return value.clamp(0, 100).toDouble();
}

class FluentProgressBar extends StatelessWidget {
  const FluentProgressBar({
    super.key,
    required this.percent,
    this.status = FluentStatus.none,
    this.type = FluentProgressType.line,
    this.showInfo = true,
    this.label = 'Progress',
  });
  final double percent;
  final FluentStatus status;
  final FluentProgressType type;
  final bool showInfo;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = FluentTheme.tokensOf(context);
    final value = normalizeFluentPercent(percent);
    final completed = value >= 100 && status != FluentStatus.error;
    final color = status == FluentStatus.error
        ? t.colorPaletteRedBackground3
        : status == FluentStatus.warning
        ? t.colorPaletteDarkOrangeBackground3
        : completed || status == FluentStatus.success
        ? t.colorPaletteGreenBackground3
        : t.colorCompoundBrandBackground;
    final info = ExcludeSemantics(
      child:
          completed ||
              status == FluentStatus.success ||
              status == FluentStatus.error
          ? FluentIcon(
              status == FluentStatus.error
                  ? FluentIconType.error
                  : FluentIconType.success,
              color: color,
            )
          : FluentText('${value.round()}%'),
    );
    return Semantics(
      label: label,
      value: '${value.round()}%',
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: value / 100),
        duration: Duration(
          milliseconds: FluentTheme.motionEnabled(context) ? 200 : 0,
        ),
        builder: (context, fraction, _) => type == FluentProgressType.circle
            ? SizedBox.square(
                dimension: 120,
                child: CustomPaint(
                  painter: _ProgressCircle(
                    fraction,
                    color,
                    t.colorNeutralBackground6,
                  ),
                  child: Center(child: showInfo ? info : null),
                ),
              )
            : Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 4,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: t.colorNeutralBackground6,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      alignment: AlignmentDirectional.centerStart,
                      child: FractionallySizedBox(
                        widthFactor: fraction,
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (showInfo) ...[const SizedBox(width: 8), info],
                ],
              ),
      ),
    );
  }
}

class _ProgressCircle extends CustomPainter {
  _ProgressCircle(this.fraction, this.color, this.track);
  final double fraction;
  final Color color, track;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(3);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, paint..color = track);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * fraction,
      false,
      paint..color = color,
    );
  }

  @override
  bool shouldRepaint(_ProgressCircle oldDelegate) =>
      fraction != oldDelegate.fraction ||
      color != oldDelegate.color ||
      track != oldDelegate.track;
}

class FluentSkeleton extends StatelessWidget {
  const FluentSkeleton({
    super.key,
    this.rows = 3,
    this.avatar = false,
    this.label = 'Loading content',
  }) : assert(rows > 0);
  final int rows;
  final bool avatar;
  final String label;
  @override
  Widget build(BuildContext context) {
    final t = FluentTheme.tokensOf(context);
    return Semantics(
      label: label,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (avatar) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: t.colorNeutralStencil1,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var index = 0; index < rows; index++) ...[
                  if (index > 0) const SizedBox(height: 16),
                  FractionallySizedBox(
                    widthFactor: index == rows - 1 ? 0.6 : 1,
                    child: Container(
                      height: 16,
                      decoration: BoxDecoration(
                        color: t.colorNeutralStencil1,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FluentEmptyState extends StatelessWidget {
  const FluentEmptyState({
    super.key,
    this.description = 'No data',
    this.action,
  });
  final String description;
  final Widget? action;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          FluentIcon(
            FluentIconType.inbox,
            size: 56,
            color: FluentTheme.tokensOf(context).colorNeutralForeground4,
          ),
          const SizedBox(height: 8),
          FluentText(description, type: FluentTextType.tertiary),
          if (action != null) ...[const SizedBox(height: 8), action!],
        ],
      ),
    ),
  );
}
