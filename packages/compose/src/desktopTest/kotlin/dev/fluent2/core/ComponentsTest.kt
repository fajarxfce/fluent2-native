package dev.fluent2.core

import androidx.compose.foundation.layout.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.input.key.Key
import androidx.compose.ui.semantics.SemanticsActions
import androidx.compose.ui.semantics.SemanticsProperties
import androidx.compose.ui.state.ToggleableState
import androidx.compose.ui.test.*
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.unit.dp
import org.junit.Rule
import org.junit.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

@OptIn(ExperimentalTestApi::class)
class ComponentsTest {
    @get:Rule val ui = createComposeRule()

    @Test fun buttonSuppressesLoadingAndDisabledActivations() {
        var calls = 0
        var loading by mutableStateOf(false)
        ui.setContent { FluentTheme(motion = false) { FluentButton(onClick = { calls++ }, loading = loading) { FluentText("Save") } } }
        ui.onNodeWithText("Save").performClick()
        assertEquals(1, calls)
        ui.runOnIdle { loading = true }
        ui.onNodeWithText("Save").assertIsNotEnabled().performClick()
        assertEquals(1, calls)
        ui.runOnIdle { loading = false }
        ui.onNodeWithText("Save").assertIsEnabled().performClick()
        assertEquals(2, calls)
    }

    @Test fun inputClearUpdatesControlledValue() {
        var value by mutableStateOf("first@example.com")
        ui.setContent { FluentTheme(motion = false) { FluentInput(value, { value = it }, Modifier.width(320.dp), label = "Email", allowClear = true) } }
        ui.onNodeWithContentDescription("Clear input").performClick()
        ui.runOnIdle { assertEquals("", value) }
        ui.onNodeWithContentDescription("Email").performTextInput("new@example.com")
        ui.runOnIdle { assertEquals("new@example.com", value) }
    }

    @Test fun indeterminateCheckboxExposesStateAndBecomesChecked() {
        var checked by mutableStateOf<Boolean?>(null)
        ui.setContent { FluentTheme(motion = false) { FluentCheckbox(checked, { checked = it }, label = "Choice") } }
        ui.onNodeWithText("Choice").assert(SemanticsMatcher.expectValue(SemanticsProperties.ToggleableState, ToggleableState.Indeterminate)).performClick()
        ui.onNodeWithText("Choice").assertIsOn()
        ui.onNodeWithText("Choice").performClick().assertIsOff()
    }

    @Test fun segmentedKeyboardSkipsDisabledOptions() {
        var value by mutableIntStateOf(1)
        ui.setContent { FluentTheme(motion = false) { FluentToggleGroup(value, listOf(FluentOption(1, "One"), FluentOption(2, "Two", false), FluentOption(3, "Three")), { value = it }) } }
        ui.onNodeWithText("One").performSemanticsAction(SemanticsActions.RequestFocus) { it() }
        ui.onNodeWithText("One").performKeyInput { pressKey(Key.DirectionRight) }
        ui.runOnIdle { assertEquals(3, value) }
        ui.onNodeWithText("Three").performKeyInput { pressKey(Key.DirectionRight) }
        ui.runOnIdle { assertEquals(1, value) }
    }

    @Test fun selectCommitsOptionAndClosesPopup() {
        var value by mutableStateOf("designer")
        ui.setContent { FluentTheme(tokens = FluentTokens.dark, motion = false) { FluentDropdown(value,
            listOf(FluentOption("designer", "Designer"), FluentOption("developer", "Developer"), FluentOption("archived", "Archived", false)),
            { value = it }, Modifier.width(300.dp), label = "Role") } }
        ui.onNodeWithContentDescription("Role").performClick()
        ui.onNodeWithText("Archived").assertIsNotEnabled()
        ui.onNodeWithText("Developer").performClick()
        ui.runOnIdle { assertEquals("developer", value) }
        ui.onNodeWithText("Archived").assertDoesNotExist()
    }

    @Test fun modalCannotBeDismissedWhileConfirming() {
        var open by mutableStateOf(true)
        var busy by mutableStateOf(false)
        ui.setContent { FluentTheme(motion = false) { FluentDialog(open, "Confirm", { open = false }, { busy = true }, confirmLoading = busy) { FluentText("Details") } } }
        ui.onNodeWithText("OK").performClick()
        ui.onNodeWithText("Cancel").assertIsNotEnabled().performClick()
        ui.runOnIdle { assertTrue(open) }
        ui.onNodeWithText("OK").assertIsNotEnabled()
        ui.runOnIdle { busy = false }
        ui.onNodeWithText("Cancel").performClick()
        ui.onNodeWithText("Details").assertDoesNotExist()
    }
}
