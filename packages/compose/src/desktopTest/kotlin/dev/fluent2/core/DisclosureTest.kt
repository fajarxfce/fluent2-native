package dev.fluent2.core

import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.foundation.layout.width
import androidx.compose.ui.input.key.Key
import androidx.compose.ui.semantics.SemanticsActions
import androidx.compose.ui.test.*
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.unit.dp
import org.junit.Rule
import org.junit.Test
import kotlin.test.assertEquals

@OptIn(ExperimentalTestApi::class)
class DisclosureTest {
    @get:Rule val ui = createComposeRule()

    @Test fun accordionNavigationSkipsDisabledAndOnlyOpensOneSection() {
        var expanded by mutableStateOf(setOf("a"))
        ui.setContent { FluentTheme(motion = false) {
            FluentAccordion(listOf(
                FluentAccordionItem("a", "First") { FluentText("First details") },
                FluentAccordionItem("b", "Unavailable", false) { FluentText("Unavailable details") },
                FluentAccordionItem("c", "Last") { FluentText("Last details") },
            ), expanded, { expanded = it }, Modifier.width(320.dp))
        } }
        ui.onNodeWithText("First").performSemanticsAction(SemanticsActions.RequestFocus) { it() }
        ui.onNodeWithText("First").performKeyInput { pressKey(Key.DirectionDown) }
        ui.onNodeWithText("Last").assertIsFocused().performKeyInput { pressKey(Key.Enter) }
        ui.runOnIdle { assertEquals(setOf("c"), expanded) }
        ui.onNodeWithText("First details").assertDoesNotExist()
        ui.onNodeWithText("Last details").assertExists()
        ui.onNodeWithText("Last").performClick()
        ui.onNodeWithText("Last details").assertDoesNotExist()
    }

    @Test fun textareaPreservesLineBreaks() {
        var value by mutableStateOf("")
        ui.setContent { FluentTheme(motion = false) { FluentTextarea(value, { value = it }, Modifier.width(320.dp), label = "Notes") } }
        ui.onNodeWithContentDescription("Notes").performTextInput("First line\nSecond line")
        ui.runOnIdle { assertEquals("First line\nSecond line", value) }
    }

    @Test fun breadcrumbNavigatesAncestorsAndMarksCurrentPage() {
        var destination = ""
        ui.setContent { FluentTheme(motion = false) {
            FluentBreadcrumb(listOf(FluentBreadcrumbItem("home", "Home"), FluentBreadcrumbItem("here", "Components")), { destination = it })
        } }
        ui.onNodeWithText("Home").performClick()
        assertEquals("home", destination)
        ui.onNodeWithText("Components").assertHasNoClickAction()
    }
}
