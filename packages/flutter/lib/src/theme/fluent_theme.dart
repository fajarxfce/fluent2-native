import 'package:flutter/material.dart';

import 'fluent_icon_type.dart';
import 'fluent_tokens.dart';

enum FluentSize { small, middle, large }

enum FluentStatus { none, success, warning, error, info }

enum FluentButtonType { primary, secondary, outline, subtle, transparent }

enum FluentTextType {
  primary,
  secondary,
  tertiary,
  disabled,
  success,
  warning,
  danger,
}

@immutable
class FluentThemeData {
  const FluentThemeData({
    this.tokens = FluentTokens.light,
    this.size = FluentSize.middle,
    this.minimumTouchTarget = 44,
    this.motion = true,
  }) : assert(minimumTouchTarget >= 0);

  final FluentTokens tokens;
  final FluentSize size;
  final double minimumTouchTarget;
  final bool motion;

  FluentThemeData copyWith({
    FluentTokens? tokens,
    FluentSize? size,
    double? minimumTouchTarget,
    bool? motion,
  }) => FluentThemeData(
    tokens: tokens ?? this.tokens,
    size: size ?? this.size,
    minimumTouchTarget: minimumTouchTarget ?? this.minimumTouchTarget,
    motion: motion ?? this.motion,
  );

  TextStyle get textStyle => TextStyle(
    inherit: false,
    fontSize: tokens.fontSizeBase300,
    height: tokens.bodyLineHeight,
    color: tokens.colorNeutralForeground1,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    textBaseline: TextBaseline.alphabetic,
    fontFamily: null,
  );

  /// Text editing, selection, popup navigation and dialogs use Flutter's
  /// platform services. Their visual styles are supplied by Fluent components.
  ThemeData get materialTheme => ThemeData(
    brightness: tokens.isDark ? Brightness.dark : Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: tokens.colorBrandBackground,
      brightness: tokens.isDark ? Brightness.dark : Brightness.light,
      surface: tokens.colorNeutralBackground1,
    ),
    scaffoldBackgroundColor: tokens.colorNeutralBackground3,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: tokens.colorBrandBackground,
      selectionColor: tokens.colorBrandBackground.withValues(alpha: 0.2),
      selectionHandleColor: tokens.colorBrandBackground,
    ),
    splashFactory: NoSplash.splashFactory,
  );
}

/// Content styling for compound Fluent controls, independent of Material defaults.
class FluentContentStyle extends InheritedWidget {
  const FluentContentStyle({
    super.key,
    required this.style,
    required super.child,
  });
  final TextStyle style;
  static TextStyle? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FluentContentStyle>()?.style;
  @override
  bool updateShouldNotify(FluentContentStyle oldWidget) =>
      style != oldWidget.style;
}

class FluentTheme extends StatelessWidget {
  const FluentTheme({super.key, required this.data, required this.child});
  final FluentThemeData data;
  final Widget child;

  static FluentThemeData of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<_FluentInheritedTheme>()
          ?.data ??
      const FluentThemeData();
  static FluentTokens tokensOf(BuildContext context) => of(context).tokens;
  static bool motionEnabled(BuildContext context) =>
      of(context).motion && !MediaQuery.disableAnimationsOf(context);

  @override
  Widget build(BuildContext context) => _FluentInheritedTheme(
    data: data,
    child: DefaultTextStyle(
      style: data.textStyle,
      child: IconTheme(
        data: IconThemeData(
          color: data.tokens.colorNeutralForeground1,
          size: 16,
        ),
        child: Theme(data: data.materialTheme, child: child),
      ),
    ),
  );
}

class _FluentInheritedTheme extends InheritedTheme {
  const _FluentInheritedTheme({required this.data, required super.child});
  final FluentThemeData data;

  @override
  bool updateShouldNotify(_FluentInheritedTheme oldWidget) =>
      data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) =>
      FluentTheme(data: data, child: child);
}

extension FluentTokenValues on FluentTokens {
  // Native equivalents of Fluent's component field-height recipes.
  double controlSize(FluentSize size) => switch (size) {
    FluentSize.small => 24,
    FluentSize.middle => 32,
    FluentSize.large => 40,
  };
  double radiusFor(FluentSize size) => borderRadiusMedium;
  double fontSizeFor(FluentSize size) => switch (size) {
    FluentSize.small => fontSizeBase200,
    FluentSize.middle => fontSizeBase300,
    FluentSize.large => fontSizeBase400,
  };
  double lineHeightFor(FluentSize size) => switch (size) {
    FluentSize.small => lineHeightBase200,
    FluentSize.middle => lineHeightBase300,
    FluentSize.large => lineHeightBase400,
  };
  double get bodyLineHeight => lineHeightBase300 / fontSizeBase300;
  double get captionLineHeight => lineHeightBase200 / fontSizeBase200;
  double get body2LineHeight => lineHeightBase400 / fontSizeBase400;
  double get title1LineHeight => lineHeightHero900 / fontSizeHero900;
  double get title2LineHeight => lineHeightHero800 / fontSizeHero800;
  double get title3LineHeight => lineHeightHero700 / fontSizeHero700;
  double get title4LineHeight => lineHeightBase600 / fontSizeBase600;
  double get title5LineHeight => lineHeightBase500 / fontSizeBase500;
  ({Color color, Color background, Color border}) statusColors(
    FluentStatus status,
  ) => switch (status) {
    FluentStatus.none => (
      color: colorNeutralForeground2,
      background: colorSubtleBackgroundHover,
      border: colorNeutralStroke1,
    ),
    FluentStatus.success => (
      color: colorStatusSuccessForeground1,
      background: colorStatusSuccessBackground1,
      border: colorStatusSuccessBorder1,
    ),
    FluentStatus.warning => (
      color: colorStatusWarningForeground1,
      background: colorStatusWarningBackground1,
      border: colorStatusWarningBorder1,
    ),
    FluentStatus.error => (
      color: colorStatusDangerForeground1,
      background: colorStatusDangerBackground1,
      border: colorStatusDangerBorder1,
    ),
    FluentStatus.info => (
      color: colorBrandForeground1,
      background: colorNeutralBackground2,
      border: colorNeutralStroke1,
    ),
  };
}

extension FluentStatusIcon on FluentStatus {
  FluentIconType get icon => switch (this) {
    FluentStatus.success => FluentIconType.success,
    FluentStatus.warning => FluentIconType.warning,
    FluentStatus.error => FluentIconType.error,
    _ => FluentIconType.info,
  };
}
