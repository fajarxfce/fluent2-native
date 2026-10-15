package dev.fluent2.core

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.hoverable
import androidx.compose.foundation.interaction.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawWithContent
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.semantics.*
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

/** Native Fluent Button. The five appearances follow Microsoft's Button recipe. */
@Composable
fun FluentButton(
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    type: FluentButtonType = FluentButtonType.Secondary,
    size: FluentSize = FluentTheme.config.size,
    danger: Boolean = false,
    enabled: Boolean = true,
    loading: Boolean = false,
    block: Boolean = false,
    icon: FluentIconType? = null,
    contentDescription: String? = null,
    loadingLabel: String = "Loading",
    content: @Composable RowScope.() -> Unit,
) {
    val t = FluentTheme.tokens
    val interaction = remember { MutableInteractionSource() }
    val hovered by interaction.collectIsHoveredAsState()
    val pressed by interaction.collectIsPressedAsState()
    val focused by interaction.collectIsFocusedAsState()
    val plain = type == FluentButtonType.Subtle || type == FluentButtonType.Transparent
    val accent = when {
        danger && pressed -> t.colorStatusDangerBackground3Pressed
        danger && hovered -> t.colorStatusDangerBackground3Hover
        danger -> t.colorStatusDangerBackground3
        pressed -> t.colorBrandBackgroundPressed
        hovered -> t.colorBrandBackgroundHover
        else -> t.colorBrandBackground
    }
    val background = when {
        !enabled -> if (plain) Color.Transparent else t.colorNeutralBackgroundDisabled
        type == FluentButtonType.Primary -> accent
        type == FluentButtonType.Outline || type == FluentButtonType.Transparent -> Color.Transparent
        type == FluentButtonType.Subtle -> when { pressed -> t.colorSubtleBackgroundPressed; hovered -> t.colorSubtleBackgroundHover; else -> Color.Transparent }
        pressed -> t.colorNeutralBackground1Pressed
        hovered -> t.colorNeutralBackground1Hover
        else -> t.colorNeutralBackground1
    }
    val foreground = when {
        !enabled -> t.colorNeutralForegroundDisabled
        type == FluentButtonType.Primary -> t.colorNeutralForegroundOnBrand
        danger -> t.colorStatusDangerForeground1
        type == FluentButtonType.Transparent && pressed -> t.colorNeutralForeground2BrandPressed
        type == FluentButtonType.Transparent && hovered -> t.colorNeutralForeground2BrandHover
        plain -> t.colorNeutralForeground2
        else -> t.colorNeutralForeground1
    }
    val border = when {
        plain || type == FluentButtonType.Primary -> Color.Transparent
        !enabled -> t.colorNeutralStrokeDisabled
        pressed -> t.colorNeutralStroke1Pressed
        hovered -> t.colorNeutralStroke1Hover
        else -> t.colorNeutralStroke1
    }
    val radius = t.borderRadiusMedium
    val shape = RoundedCornerShape(radius.dp)
    Box(modifier.then(if (block) Modifier.fillMaxWidth() else Modifier)
        .sizeIn(minHeight = FluentTheme.config.minimumTouchTarget)
        .semantics { if (contentDescription != null) this.contentDescription = contentDescription; if (loading) stateDescription = loadingLabel }
        .hoverable(interaction, enabled && !loading)
        .clickable(interaction, null, enabled && !loading, role = Role.Button, onClick = onClick),
        contentAlignment = Alignment.Center) {
        Row(Modifier.then(if (block) Modifier.fillMaxWidth() else Modifier)
            .fluentFocusRing(focused, radius, t.colorStrokeFocus2)
            .background(background, shape).border(t.strokeWidthThin.dp, border, shape)
            .heightIn(min = t.height(size))
            .padding(horizontal = if (size == FluentSize.Small) 8.dp else 12.dp, vertical = 4.dp),
            horizontalArrangement = Arrangement.spacedBy(6.dp, Alignment.CenterHorizontally), verticalAlignment = Alignment.CenterVertically) {
            CompositionLocalProvider(LocalFluentContentColor provides foreground,
                LocalFluentTextStyle provides TextStyle(color = foreground, fontSize = t.fontSizeFor(size).sp,
                    lineHeight = t.lineHeightFor(size).sp, fontWeight = FontWeight.SemiBold)) {
                if (loading) FluentSpinner(size = 16.dp, color = foreground, label = loadingLabel)
                else if (icon != null) FluentIcon(icon, size = if (size == FluentSize.Large) 24.dp else 20.dp, color = foreground)
                content()
            }
        }
    }
}

internal fun Modifier.fluentFocusRing(focused: Boolean, radius: Float, color: Color): Modifier = if (!focused) this else drawWithContent {
    drawContent()
    val inset = 1.dp.toPx()
    drawRoundRect(color, Offset(inset, inset), Size((size.width - 2 * inset).coerceAtLeast(0f), (size.height - 2 * inset).coerceAtLeast(0f)),
        cornerRadius = CornerRadius(radius.dp.toPx()), style = Stroke(2.dp.toPx()))
}
