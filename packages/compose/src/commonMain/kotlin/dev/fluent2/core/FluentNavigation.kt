package dev.fluent2.core

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsFocusedAsState
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.selection.selectable
import androidx.compose.foundation.selection.selectableGroup
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.focus.onFocusChanged
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.key.*
import androidx.compose.ui.layout.onSizeChanged
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.unit.*
import androidx.compose.ui.window.Popup
import androidx.compose.ui.window.PopupProperties

@Immutable
data class FluentOption<T : Any>(val value: T, val label: String, val enabled: Boolean = true)

internal fun <T : Any> validateOptions(options: List<FluentOption<T>>) {
    require(options.map { it.value }.distinct().size == options.size) { "Option values must be unique" }
}

internal fun <T : Any> nextEnabledOption(options: List<FluentOption<T>>, current: Int, direction: Int): Int? {
    if (options.isEmpty()) return null
    for (step in 1..options.size) {
        val index = ((current + direction * step) % options.size + options.size) % options.size
        if (options[index].enabled) return index
    }
    return null
}

@Composable
fun <T : Any> FluentDropdown(
    value: T?,
    options: List<FluentOption<T>>,
    onValueChange: ((T) -> Unit)?,
    modifier: Modifier = Modifier,
    placeholder: String = "Select an option",
    label: String? = null,
    enabled: Boolean = true,
    size: FluentSize = FluentTheme.config.size,
) {
    validateOptions(options)
    val t = FluentTheme.tokens
    var expanded by remember { mutableStateOf(false) }
    var measured by remember { mutableStateOf(IntSize.Zero) }
    var focusedIndex by remember { mutableIntStateOf(-1) }
    val requesters = remember(options) { options.map { FocusRequester() } }
    val active = enabled && onValueChange != null && options.any { it.enabled }
    val selected = options.firstOrNull { it.value == value }
    val popupWidth = with(LocalDensity.current) { measured.width.toDp() }
    LaunchedEffect(active) { if (!active) expanded = false }
    Box(modifier.widthIn(min = 160.dp).onSizeChanged { measured = it }) {
        FluentButton(onClick = { expanded = !expanded }, enabled = active, size = size, block = true,
            contentDescription = label) {
            FluentText(selected?.label ?: placeholder, Modifier.weight(1f), type = if (selected == null) FluentTextType.Tertiary else FluentTextType.Primary)
            FluentIcon(FluentIconType.Down, size = 12.dp, color = t.colorNeutralForeground3)
        }
        if (expanded) Popup(
            alignment = Alignment.TopStart, offset = IntOffset(0, measured.height + 4),
            onDismissRequest = { expanded = false }, properties = PopupProperties(focusable = true),
        ) {
            LaunchedEffect(options) {
                val index = options.indexOfFirst { it.value == value && it.enabled }.takeIf { it >= 0 }
                    ?: options.indexOfFirst { it.enabled }.takeIf { it >= 0 }
                if (index != null) requesters[index].requestFocus()
            }
            Column(Modifier.width(popupWidth).heightIn(max = 280.dp)
                .shadow(8.dp, RoundedCornerShape(t.borderRadiusMedium.dp))
                .background(t.colorNeutralBackground1, RoundedCornerShape(t.borderRadiusMedium.dp))
                .border(1.dp, t.colorNeutralStroke2, RoundedCornerShape(t.borderRadiusMedium.dp))
                .onPreviewKeyEvent { event ->
                    if (event.type != KeyEventType.KeyDown) false
                    else if (event.key == Key.Escape) { expanded = false; true }
                    else {
                        val next = when (event.key) {
                            Key.DirectionDown -> nextEnabledOption(options, focusedIndex, 1)
                            Key.DirectionUp -> nextEnabledOption(options, focusedIndex, -1)
                            Key.MoveHome -> options.indexOfFirst { it.enabled }.takeIf { it >= 0 }
                            Key.MoveEnd -> options.indexOfLast { it.enabled }.takeIf { it >= 0 }
                            else -> null
                        }
                        if (next != null) { requesters[next].requestFocus(); true } else false
                    }
                }.verticalScroll(rememberScrollState()).padding(4.dp).selectableGroup()) {
                options.forEachIndexed { index, option ->
                    val interaction = remember { MutableInteractionSource() }
                    val focused by interaction.collectIsFocusedAsState()
                    Row(Modifier.fillMaxWidth().focusRequester(requesters[index]).onFocusChanged { if (it.isFocused) focusedIndex = index }
                        .background(when { option.value == value -> t.colorNeutralBackground1Selected; focused -> t.colorSubtleBackgroundHover; else -> Color.Transparent }, RoundedCornerShape(t.borderRadiusMedium.dp))
                        .selectable(option.value == value, interaction, null, option.enabled, Role.DropdownList) {
                            expanded = false
                            onValueChange?.invoke(option.value)
                        }.heightIn(min = maxOf(32.dp, FluentTheme.config.minimumTouchTarget)).padding(horizontal = 12.dp, vertical = 5.dp),
                        verticalAlignment = Alignment.CenterVertically) {
                        FluentText(option.label, Modifier.weight(1f), strong = option.value == value, type = if (option.enabled) FluentTextType.Primary else FluentTextType.Disabled)
                        if (option.value == value) FluentIcon(FluentIconType.Check, size = 14.dp, color = t.colorBrandBackground)
                    }
                }
            }
        }
    }
}

@Composable
fun <T : Any> FluentToggleGroup(
    value: T,
    options: List<FluentOption<T>>,
    onValueChange: (T) -> Unit,
    modifier: Modifier = Modifier,
    block: Boolean = false,
) = FluentOptionBar(value, options, onValueChange, modifier, segmented = true, block = block)

@Composable
fun <T : Any> FluentTabList(
    value: T,
    options: List<FluentOption<T>>,
    onValueChange: (T) -> Unit,
    modifier: Modifier = Modifier,
    content: @Composable (T) -> Unit,
) {
    Column(modifier, verticalArrangement = Arrangement.spacedBy(16.dp)) {
        FluentOptionBar(value, options, onValueChange, Modifier.fillMaxWidth(), segmented = false, block = false)
        content(value)
    }
}

@Composable
private fun <T : Any> FluentOptionBar(value: T, options: List<FluentOption<T>>, onValueChange: (T) -> Unit, modifier: Modifier, segmented: Boolean, block: Boolean) {
    validateOptions(options)
    val t = FluentTheme.tokens
    val rtl = LocalLayoutDirection.current == LayoutDirection.Rtl
    val requesters = remember(options) { options.map { FocusRequester() } }
    var focusedIndex by remember { mutableIntStateOf(options.indexOfFirst { it.value == value }) }
    Row(modifier.then(if (segmented) Modifier.background(t.colorNeutralBackground3, RoundedCornerShape(t.borderRadiusMedium.dp)).padding(2.dp) else Modifier).then(if (block) Modifier.fillMaxWidth() else Modifier.horizontalScroll(rememberScrollState()))
        .selectableGroup().onPreviewKeyEvent { event ->
            if (event.type != KeyEventType.KeyDown) false else {
                val next = when (event.key) {
                    Key.DirectionRight -> nextEnabledOption(options, focusedIndex, if (rtl) -1 else 1)
                    Key.DirectionLeft -> nextEnabledOption(options, focusedIndex, if (rtl) 1 else -1)
                    Key.MoveHome -> options.indexOfFirst { it.enabled }.takeIf { it >= 0 }
                    Key.MoveEnd -> options.indexOfLast { it.enabled }.takeIf { it >= 0 }
                    else -> null
                }
                if (next != null) { requesters[next].requestFocus(); onValueChange(options[next].value); true } else false
            }
        }, verticalAlignment = Alignment.CenterVertically) {
        options.forEachIndexed { index, option ->
            val selected = option.value == value
            val interaction = remember { MutableInteractionSource() }
            val focused by interaction.collectIsFocusedAsState()
            Box(Modifier.then(if (block) Modifier.weight(1f) else Modifier)
                .focusRequester(requesters[index]).onFocusChanged { if (it.isFocused) focusedIndex = index }
                .then(if (segmented && selected) Modifier.shadow(1.dp, RoundedCornerShape(t.borderRadiusMedium.dp)).background(t.colorNeutralBackground1, RoundedCornerShape(t.borderRadiusMedium.dp)) else Modifier)
                .then(if (!segmented && selected) Modifier.drawBehind {
                    drawLine(t.colorBrandBackground, Offset(16.dp.toPx(), size.height - 1.dp.toPx()), Offset(size.width - 16.dp.toPx(), size.height - 1.dp.toPx()), 2.dp.toPx())
                } else Modifier)
                .fluentFocusRing(focused, t.borderRadiusMedium, t.colorStrokeFocus2)
                .selectable(selected, interaction, null, option.enabled, Role.Tab) { onValueChange(option.value) }
                .heightIn(min = maxOf(if (segmented) 28.dp else 36.dp, FluentTheme.config.minimumTouchTarget))
                .padding(horizontal = if (segmented) 12.dp else 16.dp, vertical = 4.dp), contentAlignment = Alignment.Center) {
                FluentText(option.label, strong = selected && !segmented, color = when { !option.enabled -> t.colorNeutralForegroundDisabled; selected && !segmented -> t.colorCompoundBrandForeground1; else -> t.colorNeutralForeground1 })
            }
        }
    }
}
