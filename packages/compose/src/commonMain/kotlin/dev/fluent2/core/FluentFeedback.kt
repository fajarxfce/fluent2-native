package dev.fluent2.core

import androidx.compose.animation.core.*
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.semantics.*
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import kotlin.math.roundToInt

/** Fluent's arc spinner, with a static arc when motion is disabled. */
@Composable
fun FluentSpinner(modifier: Modifier = Modifier, size: Dp = 20.dp, color: Color = FluentTheme.tokens.colorBrandBackground, label: String = "Loading") {
    val angle = if (FluentTheme.config.motion) {
        val transition = rememberInfiniteTransition(label = "fluent-spinner")
        val value by transition.animateFloat(0f, 360f, infiniteRepeatable(tween(1500, easing = LinearEasing)), label = "rotation")
        value
    } else 0f
    val track = FluentTheme.tokens.colorNeutralStroke2
    Canvas(modifier.size(size).rotate(angle).semantics { contentDescription = label; progressBarRangeInfo = ProgressBarRangeInfo.Indeterminate }) {
        val width = (this.size.minDimension / 10).coerceAtLeast(2.dp.toPx())
        val origin = Offset(width / 2, width / 2)
        val arcSize = Size(this.size.width - width, this.size.height - width)
        drawArc(track, 0f, 360f, false, origin, arcSize, style = Stroke(width))
        drawArc(color, -90f, 270f, false, origin, arcSize, style = Stroke(width, cap = StrokeCap.Round))
    }
}

@Composable
fun FluentMessageBar(
    message: String,
    modifier: Modifier = Modifier,
    description: String? = null,
    type: FluentStatus = FluentStatus.Info,
    showIcon: Boolean = true,
    onClose: (() -> Unit)? = null,
    closeLabel: String = "Dismiss message",
) {
    val t = FluentTheme.tokens
    val colors = t.status(type)
    Row(modifier.semantics { liveRegion = LiveRegionMode.Polite }
        .background(colors.background, RoundedCornerShape(t.borderRadiusMedium.dp))
        .border(1.dp, colors.border, RoundedCornerShape(t.borderRadiusMedium.dp))
        .padding(horizontal = 12.dp, vertical = 8.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp), verticalAlignment = if (description == null) Alignment.CenterVertically else Alignment.Top) {
        if (showIcon) FluentIcon(type.icon(), Modifier.padding(top = if (description == null) 0.dp else 3.dp), size = 20.dp, color = colors.color)
        Column(Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(4.dp)) {
            FluentText(message, strong = description != null)
            if (description != null) FluentText(description)
        }
        if (onClose != null) FluentButton(onClick = onClose, type = FluentButtonType.Subtle, size = FluentSize.Small, contentDescription = closeLabel) { FluentIcon(FluentIconType.Close, size = 12.dp) }
    }
}

enum class FluentProgressType { Line, Circle }

/** Percent is clamped to 0..100. NaN and infinity are rejected. */
fun normalizeFluentPercent(percent: Float): Float {
    require(percent.isFinite()) { "percent must be finite" }
    return percent.coerceIn(0f, 100f)
}

@Composable
fun FluentProgressBar(
    percent: Float,
    modifier: Modifier = Modifier,
    status: FluentStatus = FluentStatus.Default,
    type: FluentProgressType = FluentProgressType.Line,
    showInfo: Boolean = true,
    label: String = "Progress",
) {
    val t = FluentTheme.tokens
    val value = normalizeFluentPercent(percent)
    val fraction by animateFloatAsState(value / 100, tween(if (FluentTheme.config.motion) 200 else 0))
    val completed = value >= 100 && status != FluentStatus.Error
    val color = when { status == FluentStatus.Error -> t.colorPaletteRedBackground3; status == FluentStatus.Warning -> t.colorPaletteDarkOrangeBackground3; completed || status == FluentStatus.Success -> t.colorPaletteGreenBackground3; else -> t.colorCompoundBrandBackground }
    val semantics = modifier.semantics { contentDescription = label; progressBarRangeInfo = ProgressBarRangeInfo(value, 0f..100f) }
    val info: @Composable () -> Unit = {
        if (completed || status == FluentStatus.Success || status == FluentStatus.Error) FluentIcon(if (status == FluentStatus.Error) FluentIconType.Error else FluentIconType.Success, color = color)
        else FluentText("${value.roundToInt()}%", modifier = Modifier.clearAndSetSemantics {})
    }
    if (type == FluentProgressType.Circle) {
        Box(semantics.size(120.dp), contentAlignment = Alignment.Center) {
            Canvas(Modifier.fillMaxSize()) {
                val stroke = 6.dp.toPx()
                val arcSize = Size(size.width - stroke, size.height - stroke)
                val origin = Offset(stroke / 2, stroke / 2)
                drawArc(t.colorNeutralBackground6, 0f, 360f, false, origin, arcSize, style = Stroke(stroke, cap = StrokeCap.Round))
                drawArc(color, -90f, fraction * 360, false, origin, arcSize, style = Stroke(stroke, cap = StrokeCap.Round))
            }
            if (showInfo) info()
        }
    } else {
        Row(semantics, verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            Box(Modifier.weight(1f).height(4.dp).clip(CircleShape).background(t.colorNeutralBackground6)) {
                Box(Modifier.fillMaxWidth(fraction).fillMaxHeight().background(color, CircleShape))
            }
            if (showInfo) info()
        }
    }
}

@Composable
fun FluentSkeleton(modifier: Modifier = Modifier, rows: Int = 3, avatar: Boolean = false, label: String = "Loading content") {
    require(rows > 0) { "rows must be positive" }
    val t = FluentTheme.tokens
    Row(modifier.semantics { contentDescription = label; progressBarRangeInfo = ProgressBarRangeInfo.Indeterminate }, horizontalArrangement = Arrangement.spacedBy(16.dp)) {
        if (avatar) Box(Modifier.size(40.dp).background(t.colorNeutralStencil1, CircleShape))
        Column(Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(16.dp)) {
            repeat(rows) { index -> Box(Modifier.fillMaxWidth(if (index == rows - 1) 0.6f else 1f).height(16.dp).background(t.colorNeutralStencil1, RoundedCornerShape(4.dp))) }
        }
    }
}

@Composable
fun FluentEmptyState(modifier: Modifier = Modifier, description: String = "No data", action: (@Composable () -> Unit)? = null) {
    Column(modifier.fillMaxWidth().padding(vertical = 24.dp), horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(8.dp)) {
        FluentIcon(FluentIconType.Inbox, size = 56.dp, color = FluentTheme.tokens.colorNeutralForeground4)
        FluentText(description, type = FluentTextType.Tertiary)
        if (action != null) action()
    }
}
