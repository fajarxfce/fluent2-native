package dev.fluent2.core

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsFocusedAsState
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.draw.drawWithContent
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.error
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

@Composable
fun FluentInput(
    value: String,
    onValueChange: (String) -> Unit,
    modifier: Modifier = Modifier,
    placeholder: String = "",
    label: String? = null,
    status: FluentStatus = FluentStatus.Default,
    errorMessage: String? = null,
    size: FluentSize = FluentTheme.config.size,
    enabled: Boolean = true,
    readOnly: Boolean = false,
    password: Boolean = false,
    allowClear: Boolean = false,
    singleLine: Boolean = true,
    minLines: Int = 1,
    prefix: FluentIconType? = null,
    clearLabel: String = "Clear input",
    keyboardOptions: KeyboardOptions = KeyboardOptions.Default,
    keyboardActions: KeyboardActions = KeyboardActions.Default,
) {
    val t = FluentTheme.tokens
    val interaction = remember { MutableInteractionSource() }
    val focused by interaction.collectIsFocusedAsState()
    val accent = when (status) { FluentStatus.Error -> t.colorStatusDangerBackground3; FluentStatus.Warning -> t.colorStatusWarningBackground3; else -> t.colorCompoundBrandStroke }
    val border = when { !enabled -> t.colorNeutralStrokeDisabled; status == FluentStatus.Error || status == FluentStatus.Warning -> accent; focused -> t.colorNeutralStroke1Pressed; else -> t.colorNeutralStroke1 }
    val fontSize = t.fontSizeFor(size)
    val radius = t.radius(size)
    BasicTextField(
        value, onValueChange,
        modifier = modifier.semantics {
            if (label != null) contentDescription = label
            if (status == FluentStatus.Error && errorMessage != null) error(errorMessage)
        },
        enabled = enabled, readOnly = readOnly, singleLine = singleLine, minLines = minLines,
        visualTransformation = if (password) PasswordVisualTransformation() else VisualTransformation.None,
        keyboardOptions = keyboardOptions, keyboardActions = keyboardActions,
        interactionSource = interaction, cursorBrush = SolidColor(t.colorBrandBackground),
        textStyle = TextStyle(color = if (enabled) t.colorNeutralForeground1 else t.colorNeutralForegroundDisabled, fontSize = fontSize.sp, lineHeight = t.lineHeightFor(size).sp),
        decorationBox = { inner ->
            Row(
                Modifier.clip(RoundedCornerShape(radius)).drawWithContent {
                    drawContent()
                    val stroke = if (focused) 2.dp.toPx() else 1.dp.toPx()
                    val bottom = when { !enabled -> t.colorNeutralStrokeDisabled; focused -> accent; status == FluentStatus.Error || status == FluentStatus.Warning -> accent; else -> t.colorNeutralStrokeAccessible }
                    drawLine(bottom, Offset(0f, this.size.height - stroke / 2), Offset(this.size.width, this.size.height - stroke / 2), stroke)
                }
                    .background(if (enabled) t.colorNeutralBackground1 else t.colorNeutralBackgroundDisabled, RoundedCornerShape(radius))
                    .border(t.strokeWidthThin.dp, border, RoundedCornerShape(radius))
                    .heightIn(min = maxOf(t.height(size), FluentTheme.config.minimumTouchTarget))
                    .padding(horizontal = if (size == FluentSize.Small) 7.dp else 11.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(8.dp),
            ) {
                if (prefix != null) FluentIcon(prefix, color = t.colorNeutralForeground3)
                Box(Modifier.weight(1f).padding(vertical = if (size == FluentSize.Small) 0.dp else 4.dp)) {
                    if (value.isEmpty()) FluentText(placeholder, color = t.colorNeutralForeground3, style = TextStyle(fontSize = fontSize.sp))
                    inner()
                }
                if (allowClear && value.isNotEmpty() && enabled && !readOnly) {
                    FluentButton(onClick = { onValueChange("") }, type = FluentButtonType.Subtle, size = FluentSize.Small, contentDescription = clearLabel) {
                        FluentIcon(FluentIconType.Close, size = 12.dp, color = t.colorNeutralForeground3)
                    }
                }
            }
        },
    )
}

@Composable
fun FluentField(
    label: String,
    modifier: Modifier = Modifier,
    required: Boolean = false,
    help: String? = null,
    status: FluentStatus = FluentStatus.Default,
    content: @Composable () -> Unit,
) {
    Column(modifier, verticalArrangement = Arrangement.spacedBy(6.dp)) {
        Row(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
            FluentText(label)
            if (required) FluentText("*", type = FluentTextType.Danger)
        }
        content()
        if (help != null) FluentText(help, type = when (status) {
            FluentStatus.Error -> FluentTextType.Danger
            FluentStatus.Warning -> FluentTextType.Warning
            else -> FluentTextType.Secondary
        })
    }
}
