package dev.fluent2.core

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.scale
import androidx.compose.ui.graphics.drawscope.translate
import androidx.compose.ui.graphics.vector.PathParser
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.heading
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

@Composable
fun FluentText(
    text: String,
    modifier: Modifier = Modifier,
    type: FluentTextType = FluentTextType.Primary,
    strong: Boolean = false,
    code: Boolean = false,
    underline: Boolean = false,
    color: Color = Color.Unspecified,
    style: TextStyle = TextStyle.Default,
    maxLines: Int = Int.MAX_VALUE,
) {
    val t = FluentTheme.tokens
    val resolved = if (color != Color.Unspecified) color else when (type) {
        FluentTextType.Primary -> FluentTheme.contentColor
        FluentTextType.Secondary -> t.colorNeutralForeground2
        FluentTextType.Tertiary -> t.colorNeutralForeground3
        FluentTextType.Disabled -> t.colorNeutralForegroundDisabled
        FluentTextType.Success -> t.colorStatusSuccessForeground1
        FluentTextType.Warning -> t.colorStatusWarningForeground1
        FluentTextType.Danger -> t.colorStatusDangerForeground1
    }
    BasicText(
        text,
        modifier = if (code) modifier.background(t.colorSubtleBackgroundHover, RoundedCornerShape(3.dp)).padding(horizontal = 4.dp, vertical = 1.dp) else modifier,
        style = LocalFluentTextStyle.current.merge(TextStyle(
            color = resolved,
            fontWeight = if (strong) FontWeight.SemiBold else null,
            fontFamily = if (code) FontFamily.Monospace else null,
            textDecoration = if (underline) TextDecoration.Underline else null,
        )).merge(style),
        maxLines = maxLines,
        overflow = TextOverflow.Ellipsis,
    )
}

@Composable
fun FluentTitle(text: String, modifier: Modifier = Modifier, level: Int = 3) {
    require(level in 1..5) { "Title level must be between 1 and 5" }
    val t = FluentTheme.tokens
    val (size, height) = when (level) {
        1 -> t.fontSizeHero900 to t.title1LineHeight
        2 -> t.fontSizeHero800 to t.title2LineHeight
        3 -> t.fontSizeHero700 to t.title3LineHeight
        4 -> t.fontSizeBase600 to t.title4LineHeight
        else -> t.fontSizeBase500 to t.title5LineHeight
    }
    FluentText(text, modifier.semantics { heading() }, strong = true, style = TextStyle(fontSize = size.sp, lineHeight = (size * height).sp))
}

@Composable
fun FluentIcon(
    icon: FluentIconType,
    modifier: Modifier = Modifier,
    size: Dp = 16.dp,
    color: Color = FluentTheme.contentColor,
    contentDescription: String? = null,
) {
    val paths = remember(icon) { icon.paths.map { PathParser().parsePathString(it).toPath() } }
    Canvas(modifier.size(size).semantics { if (contentDescription != null) this.contentDescription = contentDescription }) {
        scale(this.size.width / icon.viewWidth, this.size.height / icon.viewHeight, pivot = androidx.compose.ui.geometry.Offset.Zero) {
            translate(-icon.viewX, -icon.viewY) { paths.forEach { drawPath(it, color) } }
        }
    }
}
