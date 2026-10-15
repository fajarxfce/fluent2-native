package dev.fluent2.core

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.semantics.clearAndSetSemantics
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

@Composable
fun FluentCard(modifier: Modifier = Modifier, title: String? = null, extra: (@Composable () -> Unit)? = null,
    size: FluentSize = FluentTheme.config.size, bordered: Boolean = true, content: @Composable ColumnScope.() -> Unit) {
    val t = FluentTheme.tokens
    val shape = RoundedCornerShape(if (size == FluentSize.Large) t.borderRadiusLarge.dp else t.borderRadiusMedium.dp)
    val padding = when (size) { FluentSize.Small -> 8.dp; FluentSize.Middle -> 12.dp; FluentSize.Large -> 16.dp }
    Column(modifier.shadow(2.dp, shape).clip(shape).background(t.colorNeutralBackground1)
        .then(if (bordered) Modifier.border(1.dp, t.colorNeutralStrokeAlpha, shape) else Modifier)
        .padding(padding), verticalArrangement = Arrangement.spacedBy(padding)) {
        if (title != null || extra != null) Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            if (title != null) FluentText(title, Modifier.weight(1f), strong = true) else Spacer(Modifier.weight(1f))
            if (extra != null) extra()
        }
        content()
    }
}

enum class FluentBadgeAppearance { Filled, Outline }

@Composable
fun FluentBadge(text: String, modifier: Modifier = Modifier, status: FluentStatus = FluentStatus.Default,
    icon: FluentIconType? = null, appearance: FluentBadgeAppearance = FluentBadgeAppearance.Filled) {
    val t = FluentTheme.tokens
    val color = when (status) {
        FluentStatus.Default -> t.colorNeutralBackground5
        FluentStatus.Info -> t.colorBrandBackground
        FluentStatus.Success -> t.colorPaletteGreenBackground3
        FluentStatus.Warning -> t.colorPaletteDarkOrangeBackground3
        FluentStatus.Error -> t.colorPaletteRedBackground3
    }
    val filled = appearance == FluentBadgeAppearance.Filled
    val foreground = if (status == FluentStatus.Default) t.colorNeutralForeground3 else if (filled) t.colorNeutralForegroundOnBrand else color
    Row(modifier.background(if (filled) color else Color.Transparent, CircleShape)
        .border(1.dp, if (filled) Color.Transparent else if (status == FluentStatus.Default) t.colorNeutralStrokeAccessible else color, CircleShape)
        .heightIn(min = 20.dp).padding(horizontal = 6.dp, vertical = 1.dp), verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(4.dp)) {
        if (icon != null) FluentIcon(icon, size = 12.dp, color = foreground)
        FluentText(text, color = foreground, strong = true, style = TextStyle(fontSize = t.fontSizeBase200.sp, lineHeight = t.lineHeightBase200.sp))
    }
}

fun formatFluentCount(count: Int, overflowCount: Int = 99): String {
    require(count >= 0) { "count must not be negative" }
    require(overflowCount > 0) { "overflowCount must be positive" }
    return if (count > overflowCount) "$overflowCount+" else "$count"
}

@Composable
fun FluentCounterBadge(
    count: Int = 0,
    modifier: Modifier = Modifier,
    dot: Boolean = false,
    showZero: Boolean = false,
    overflowCount: Int = 99,
    label: String = if (dot) "New activity" else "$count notifications",
    content: @Composable () -> Unit,
) {
    val t = FluentTheme.tokens
    val text = formatFluentCount(count, overflowCount)
    val visible = dot || count > 0 || showZero
    Box(modifier.semantics { if (visible) contentDescription = label }) {
        content()
        if (visible) Box(Modifier.align(Alignment.TopEnd).offset(x = if (dot) 3.dp else 8.dp, y = if (dot) (-3).dp else (-8).dp)
            .then(if (dot) Modifier.size(6.dp) else Modifier.heightIn(min = 20.dp).widthIn(min = 20.dp))
            .background(t.colorBrandBackground, CircleShape).border(1.dp, t.colorNeutralBackground1, CircleShape)
            .padding(horizontal = if (dot) 0.dp else 5.dp), contentAlignment = Alignment.Center) {
            if (!dot) FluentText(text, Modifier.clearAndSetSemantics {}, color = Color.White, style = TextStyle(fontSize = 12.sp, lineHeight = 18.sp))
        }
    }
}

@Composable
fun FluentAvatar(
    text: String? = null,
    modifier: Modifier = Modifier,
    size: Dp = 40.dp,
    square: Boolean = false,
    color: Color = FluentTheme.tokens.colorBrandForeground1,
    background: Color = FluentTheme.tokens.colorBrandBackground2,
    label: String? = text,
) {
    Box(modifier.size(size).clip(if (square) RoundedCornerShape(FluentTheme.tokens.borderRadiusMedium.dp) else CircleShape)
        .background(background).semantics { if (label != null) contentDescription = label }, contentAlignment = Alignment.Center) {
        if (text != null) FluentText(text, Modifier.clearAndSetSemantics {}, color = color, style = TextStyle(fontSize = (size.value * 0.4f).sp), maxLines = 1)
        else FluentIcon(FluentIconType.User, size = size * 0.5f, color = color)
    }
}

@Composable
fun FluentDivider(modifier: Modifier = Modifier, text: String? = null) {
    val t = FluentTheme.tokens
    Row(modifier.fillMaxWidth().padding(vertical = 16.dp), verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(16.dp)) {
        Box(Modifier.weight(1f).height(1.dp).background(t.colorNeutralStroke2))
        if (text != null) {
            FluentText(text, strong = true)
            Box(Modifier.weight(1f).height(1.dp).background(t.colorNeutralStroke2))
        }
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
fun FluentStack(modifier: Modifier = Modifier, gap: Dp = 8.dp, vertical: Boolean = false, content: @Composable () -> Unit) {
    if (vertical) Column(modifier, verticalArrangement = Arrangement.spacedBy(gap)) { content() }
    else FlowRow(modifier, horizontalArrangement = Arrangement.spacedBy(gap), verticalArrangement = Arrangement.spacedBy(gap), itemVerticalAlignment = Alignment.CenterVertically) { content() }
}

@Composable
fun FluentStatistic(title: String, value: String, modifier: Modifier = Modifier, prefix: String? = null, suffix: String? = null) {
    Column(modifier, verticalArrangement = Arrangement.spacedBy(4.dp)) {
        FluentText(title, type = FluentTextType.Secondary)
        Row(horizontalArrangement = Arrangement.spacedBy(4.dp), verticalAlignment = Alignment.Bottom) {
            if (prefix != null) FluentText(prefix, style = TextStyle(fontSize = 24.sp))
            FluentText(value, style = TextStyle(fontSize = 24.sp, lineHeight = 32.sp))
            if (suffix != null) FluentText(suffix)
        }
    }
}
