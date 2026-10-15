package dev.fluent2.core

import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.Immutable
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

enum class FluentSize { Small, Middle, Large }
enum class FluentStatus { Default, Success, Warning, Error, Info }
enum class FluentButtonType { Primary, Secondary, Outline, Subtle, Transparent }
enum class FluentTextType { Primary, Secondary, Tertiary, Disabled, Success, Warning, Danger }

@Immutable
data class FluentThemeConfig(
    val tokens: FluentTokens = FluentTokens.light,
    val size: FluentSize = FluentSize.Middle,
    /** Extra space around small visual controls so mobile targets remain usable. */
    val minimumTouchTarget: Dp = 44.dp,
    val motion: Boolean = true,
)

internal val LocalFluentConfig = staticCompositionLocalOf { FluentThemeConfig() }
internal val LocalFluentContentColor = staticCompositionLocalOf { FluentTokens.light.colorNeutralForeground1 }
internal val LocalFluentTextStyle = staticCompositionLocalOf { TextStyle.Default }

object FluentTheme {
    val tokens: FluentTokens @Composable get() = LocalFluentConfig.current.tokens
    val config: FluentThemeConfig @Composable get() = LocalFluentConfig.current
    val contentColor: Color @Composable get() = LocalFluentContentColor.current
}

@Composable
fun FluentTheme(
    tokens: FluentTokens = FluentTokens.light,
    size: FluentSize = FluentSize.Middle,
    minimumTouchTarget: Dp = 44.dp,
    motion: Boolean = true,
    content: @Composable () -> Unit,
) {
    require(minimumTouchTarget >= 0.dp) { "minimumTouchTarget must not be negative" }
    CompositionLocalProvider(
        LocalFluentConfig provides FluentThemeConfig(tokens, size, minimumTouchTarget, motion),
        LocalFluentContentColor provides tokens.colorNeutralForeground1,
        LocalFluentTextStyle provides TextStyle(fontSize = tokens.fontSizeBase300.sp, lineHeight = (tokens.fontSizeBase300 * tokens.bodyLineHeight).sp),
        content = content,
    )
}

internal fun FluentTokens.height(size: FluentSize): Dp = when (size) {
    FluentSize.Small -> 24.dp
    FluentSize.Middle -> 32.dp
    FluentSize.Large -> 40.dp
}

// Fluent field and button recipes keep the same corner radius in every size.
internal fun FluentTokens.radius(size: FluentSize): Dp = borderRadiusMedium.dp
internal fun FluentTokens.fontSizeFor(size: FluentSize): Float = when (size) {
    FluentSize.Small -> fontSizeBase200
    FluentSize.Middle -> fontSizeBase300
    FluentSize.Large -> fontSizeBase400
}
internal fun FluentTokens.lineHeightFor(size: FluentSize): Float = when (size) {
    FluentSize.Small -> lineHeightBase200
    FluentSize.Middle -> lineHeightBase300
    FluentSize.Large -> lineHeightBase400
}
internal val FluentTokens.bodyLineHeight get() = lineHeightBase300 / fontSizeBase300
internal val FluentTokens.captionLineHeight get() = lineHeightBase200 / fontSizeBase200
internal val FluentTokens.body2LineHeight get() = lineHeightBase400 / fontSizeBase400
internal val FluentTokens.title1LineHeight get() = lineHeightHero900 / fontSizeHero900
internal val FluentTokens.title2LineHeight get() = lineHeightHero800 / fontSizeHero800
internal val FluentTokens.title3LineHeight get() = lineHeightHero700 / fontSizeHero700
internal val FluentTokens.title4LineHeight get() = lineHeightBase600 / fontSizeBase600
internal val FluentTokens.title5LineHeight get() = lineHeightBase500 / fontSizeBase500

internal data class FluentStatusColors(val color: Color, val background: Color, val border: Color)

internal fun FluentTokens.status(status: FluentStatus): FluentStatusColors = when (status) {
    FluentStatus.Default -> FluentStatusColors(colorNeutralForeground2, colorNeutralBackground2, colorNeutralStroke1)
    FluentStatus.Success -> FluentStatusColors(colorStatusSuccessForeground1, colorStatusSuccessBackground1, colorStatusSuccessBorder1)
    FluentStatus.Warning -> FluentStatusColors(colorStatusWarningForeground1, colorStatusWarningBackground1, colorStatusWarningBorder1)
    FluentStatus.Error -> FluentStatusColors(colorStatusDangerForeground1, colorStatusDangerBackground1, colorStatusDangerBorder1)
    FluentStatus.Info -> FluentStatusColors(colorBrandForeground1, colorNeutralBackground2, colorNeutralStroke1)
}

internal fun FluentStatus.icon(): FluentIconType = when (this) {
    FluentStatus.Success -> FluentIconType.Success
    FluentStatus.Warning -> FluentIconType.Warning
    FluentStatus.Error -> FluentIconType.Error
    else -> FluentIconType.Info
}
