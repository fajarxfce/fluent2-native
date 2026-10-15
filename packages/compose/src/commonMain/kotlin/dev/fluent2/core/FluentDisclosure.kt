package dev.fluent2.core

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.horizontalScroll
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.focus.onFocusChanged
import androidx.compose.ui.input.key.*
import androidx.compose.ui.semantics.*
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.unit.dp

/** A multiline native editor with the same focus/validation recipe as Input. */
@Composable
fun FluentTextarea(value: String, onValueChange: (String) -> Unit, modifier: Modifier = Modifier,
    label: String? = null, placeholder: String = "", rows: Int = 3,
    enabled: Boolean = true, readOnly: Boolean = false, status: FluentStatus = FluentStatus.Default,
    errorMessage: String? = null) {
    require(rows > 0) { "rows must be positive" }
    FluentInput(value, onValueChange, modifier, label = label, placeholder = placeholder,
        singleLine = false, minLines = rows, enabled = enabled, readOnly = readOnly,
        status = status, errorMessage = errorMessage)
}

/** Callback-based link; navigation remains owned by the host application. */
@Composable
fun FluentLink(text: String, onClick: () -> Unit, modifier: Modifier = Modifier, enabled: Boolean = true) {
    FluentButton(onClick, modifier, type = FluentButtonType.Transparent, enabled = enabled) {
        FluentText(text, color = if (enabled) FluentTheme.tokens.colorBrandForegroundLink else FluentTheme.tokens.colorNeutralForegroundDisabled,
            style = TextStyle(fontWeight = FontWeight.Normal, textDecoration = TextDecoration.Underline))
    }
}

class FluentAccordionItem(val id: String, val title: String, val enabled: Boolean = true, val content: @Composable () -> Unit)

/** Controlled disclosure sections with Up/Down/Home/End header navigation. */
@Composable
fun FluentAccordion(items: List<FluentAccordionItem>, expanded: Set<String>, onExpandedChange: (Set<String>) -> Unit,
    modifier: Modifier = Modifier, multiple: Boolean = false) {
    require(items.map { it.id }.distinct().size == items.size) { "Accordion IDs must be unique" }
    val focus = remember(items.map { it.id }) { items.map { FocusRequester() } }
    var focused by remember { mutableIntStateOf(-1) }
    Column(modifier.onPreviewKeyEvent { event ->
        if (event.type != KeyEventType.KeyDown) false else {
            val options = items.map { FluentOption(it.id, it.title, it.enabled) }
            val next = when (event.key) {
                Key.DirectionDown -> nextEnabledOption(options, focused, 1)
                Key.DirectionUp -> nextEnabledOption(options, focused, -1)
                Key.MoveHome -> items.indexOfFirst { it.enabled }.takeIf { it >= 0 }
                Key.MoveEnd -> items.indexOfLast { it.enabled }.takeIf { it >= 0 }
                else -> null
            }
            if (next != null && focused >= 0) { focus[next].requestFocus(); true } else false
        }
    }) {
        items.forEachIndexed { index, item ->
            val open = item.id in expanded
            FluentButton(onClick = {
                onExpandedChange(if (open) expanded - item.id else if (multiple) expanded + item.id else setOf(item.id))
            }, modifier = Modifier.fillMaxWidth().focusRequester(focus[index]).onFocusChanged { if (it.isFocused) focused = index else if (focused == index) focused = -1 }
                .semantics { heading(); stateDescription = if (open) "Expanded" else "Collapsed" },
                type = FluentButtonType.Subtle, enabled = item.enabled, block = true) {
                FluentIcon(if (open) FluentIconType.Down else FluentIconType.Right, size = 20.dp)
                FluentText(item.title, Modifier.weight(1f))
            }
            if (open) Column(Modifier.fillMaxWidth().padding(start = 40.dp, end = 12.dp, bottom = 12.dp)) { item.content() }
        }
    }
}

@Immutable
data class FluentBreadcrumbItem(val id: String, val label: String)

/** The final item is the current page; ancestors invoke the host navigation callback. */
@Composable
fun FluentBreadcrumb(items: List<FluentBreadcrumbItem>, onNavigate: (String) -> Unit, modifier: Modifier = Modifier) {
    require(items.map { it.id }.distinct().size == items.size) { "Breadcrumb IDs must be unique" }
    Row(modifier.horizontalScroll(rememberScrollState()), verticalAlignment = Alignment.CenterVertically) {
        items.forEachIndexed { index, item ->
            if (index > 0) FluentIcon(FluentIconType.Right, size = 12.dp, color = FluentTheme.tokens.colorNeutralForeground3)
            if (index == items.lastIndex) FluentText(item.label, Modifier.padding(horizontal = 12.dp).semantics { stateDescription = "Current page" }, strong = true)
            else FluentLink(item.label, { onNavigate(item.id) })
        }
    }
}
