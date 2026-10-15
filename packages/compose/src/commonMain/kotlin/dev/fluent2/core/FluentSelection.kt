package dev.fluent2.core

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsFocusedAsState
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.selection.selectable
import androidx.compose.foundation.selection.toggleable
import androidx.compose.foundation.selection.triStateToggleable
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.stateDescription
import androidx.compose.ui.state.ToggleableState
import androidx.compose.ui.unit.dp

@Composable
fun FluentCheckbox(
    checked: Boolean?,
    onCheckedChange: ((Boolean) -> Unit)?,
    modifier: Modifier = Modifier,
    label: String? = null,
    enabled: Boolean = true,
) {
    val t = FluentTheme.tokens
    val active = enabled && onCheckedChange != null
    val interaction = remember { MutableInteractionSource() }
    val focused by interaction.collectIsFocusedAsState()
    val state = when (checked) { true -> ToggleableState.On; false -> ToggleableState.Off; null -> ToggleableState.Indeterminate }
    Row(modifier.sizeIn(minWidth = FluentTheme.config.minimumTouchTarget, minHeight = FluentTheme.config.minimumTouchTarget)
        .triStateToggleable(state, interaction, null, active, Role.Checkbox) { onCheckedChange?.invoke(checked != true) },
        verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
        Box(Modifier.size(16.dp).fluentFocusRing(focused, 2f, t.colorStrokeFocus2)
            .background(when { !active -> t.colorNeutralBackgroundDisabled; checked != false -> t.colorCompoundBrandBackground; else -> t.colorNeutralBackground1 }, RoundedCornerShape(2.dp))
            .border(1.dp, if (!active) t.colorNeutralStrokeDisabled else if (checked == false) t.colorNeutralStrokeAccessible else t.colorCompoundBrandStroke, RoundedCornerShape(2.dp)),
            contentAlignment = Alignment.Center) {
            if (checked != false) FluentIcon(if (checked == true) FluentIconType.Check else FluentIconType.Minus, size = 14.dp,
                color = if (!active) t.colorNeutralForegroundDisabled else t.colorNeutralForegroundOnBrand)
        }
        if (label != null) FluentText(label, type = if (active) FluentTextType.Primary else FluentTextType.Disabled)
    }
}

@Composable
fun FluentRadio(
    selected: Boolean,
    onClick: (() -> Unit)?,
    modifier: Modifier = Modifier,
    label: String? = null,
    enabled: Boolean = true,
) {
    val t = FluentTheme.tokens
    val active = enabled && onClick != null
    val interaction = remember { MutableInteractionSource() }
    val focused by interaction.collectIsFocusedAsState()
    Row(modifier.sizeIn(minWidth = FluentTheme.config.minimumTouchTarget, minHeight = FluentTheme.config.minimumTouchTarget)
        .selectable(selected, interaction, null, active, Role.RadioButton) { onClick?.invoke() },
        verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
        Box(Modifier.size(16.dp).fluentFocusRing(focused, 8f, t.colorStrokeFocus2)
            .background(if (active) t.colorNeutralBackground1 else t.colorNeutralBackgroundDisabled, CircleShape)
            .border(1.dp, if (!active) t.colorNeutralStrokeDisabled else if (selected) t.colorCompoundBrandStroke else t.colorNeutralStrokeAccessible, CircleShape), contentAlignment = Alignment.Center) {
            if (selected) Box(Modifier.size(8.dp).background(if (active) t.colorCompoundBrandForeground1 else t.colorNeutralForegroundDisabled, CircleShape))
        }
        if (label != null) FluentText(label, type = if (active) FluentTextType.Primary else FluentTextType.Disabled)
    }
}

@Composable
fun FluentSwitch(
    checked: Boolean,
    onCheckedChange: ((Boolean) -> Unit)?,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    loading: Boolean = false,
    size: FluentSize = FluentTheme.config.size,
    label: String? = null,
) {
    val t = FluentTheme.tokens
    val active = enabled && !loading && onCheckedChange != null
    val interaction = remember { MutableInteractionSource() }
    val focused by interaction.collectIsFocusedAsState()
    val small = size == FluentSize.Small
    val width = if (small) 32.dp else 40.dp
    val height = if (small) 16.dp else 20.dp
    val thumb = height - 8.dp
    val duration = if (FluentTheme.config.motion) 150 else 0
    val offset by animateDpAsState(if (checked) width - thumb - 4.dp else 4.dp, tween(duration))
    val background by animateColorAsState(if (checked) t.colorCompoundBrandBackground else Color.Transparent, tween(duration))
    Box(modifier.sizeIn(minWidth = FluentTheme.config.minimumTouchTarget, minHeight = FluentTheme.config.minimumTouchTarget)
        .semantics { if (label != null) contentDescription = label; if (loading) stateDescription = "Loading" }
        .toggleable(checked, interaction, null, active, Role.Switch) { onCheckedChange?.invoke(it) }, contentAlignment = Alignment.Center) {
        Box(Modifier.size(width, height).fluentFocusRing(focused, 100f, t.colorStrokeFocus2)
            .background(if (active) background else if (checked) t.colorNeutralBackgroundDisabled else Color.Transparent, CircleShape)
            .border(1.dp, if (!active) t.colorNeutralStrokeDisabled else if (checked) Color.Transparent else t.colorNeutralStrokeAccessible, CircleShape), contentAlignment = Alignment.CenterStart) {
            Box(Modifier.offset(x = offset).size(thumb).background(if (!active) t.colorNeutralForegroundDisabled else if (checked) t.colorNeutralForegroundOnBrand else t.colorNeutralStrokeAccessible, CircleShape), contentAlignment = Alignment.Center) {
                if (loading) FluentSpinner(size = thumb - 4.dp, color = t.colorBrandBackground)
            }
        }
    }
}
