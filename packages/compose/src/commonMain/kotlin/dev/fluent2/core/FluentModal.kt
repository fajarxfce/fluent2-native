package dev.fluent2.core

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.paneTitle
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties

/** Controlled dialog: the caller owns visibility, asynchronous work and errors. */
@Composable
fun FluentDialog(
    open: Boolean,
    title: String,
    onDismiss: () -> Unit,
    onConfirm: () -> Unit,
    modifier: Modifier = Modifier,
    confirmText: String = "OK",
    cancelText: String = "Cancel",
    closeLabel: String = "Close dialog",
    confirmLoading: Boolean = false,
    confirmEnabled: Boolean = true,
    danger: Boolean = false,
    dismissible: Boolean = true,
    content: @Composable ColumnScope.() -> Unit,
) {
    if (!open) return
    val t = FluentTheme.tokens
    Dialog(
        onDismissRequest = { if (dismissible && !confirmLoading) onDismiss() },
        properties = DialogProperties(dismissOnBackPress = dismissible && !confirmLoading,
            dismissOnClickOutside = dismissible && !confirmLoading, usePlatformDefaultWidth = false),
    ) {
        Column(modifier.padding(24.dp).widthIn(max = 520.dp).fillMaxWidth().heightIn(max = 640.dp)
            .background(t.colorNeutralBackground1, RoundedCornerShape(t.borderRadiusXLarge.dp))
            .semantics { paneTitle = title }.padding(24.dp), verticalArrangement = Arrangement.spacedBy(16.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                FluentTitle(title, Modifier.weight(1f), level = 5)
                FluentButton(onClick = onDismiss, type = FluentButtonType.Subtle, enabled = !confirmLoading, contentDescription = closeLabel) { FluentIcon(FluentIconType.Close) }
            }
            Column(Modifier.weight(1f, fill = false).verticalScroll(rememberScrollState()), verticalArrangement = Arrangement.spacedBy(12.dp), content = content)
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp, Alignment.End)) {
                FluentButton(onClick = onDismiss, enabled = !confirmLoading) { FluentText(cancelText) }
                FluentButton(onClick = onConfirm, type = FluentButtonType.Primary, danger = danger,
                    loading = confirmLoading, enabled = confirmEnabled) { FluentText(confirmText) }
            }
        }
    }
}
