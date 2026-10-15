package dev.fluent2.core

import androidx.compose.foundation.background
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toPixelMap
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.test.*
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.unit.dp
import org.junit.Rule
import org.junit.Test
import kotlin.test.assertEquals

@OptIn(ExperimentalTestApi::class)
class IconRenderingTest {
    @get:Rule val ui = createComposeRule()

    @Test fun officialAppsIconPreservesTileHolesAndOutlines() {
        ui.setContent {
            FluentIcon(FluentIconType.Grid, Modifier.background(Color.White).testTag("icon"), size = 240.dp, color = Color.Black)
        }
        val pixels = ui.onNodeWithTag("icon").captureToImage().toPixelMap()
        fun sample(x: Float, y: Float) = pixels[(x / 24 * pixels.width).toInt(), (y / 24 * pixels.height).toInt()]
        // The official Apps24Regular has three hollow squares and a hollow diamond.
        for ((x, y) in listOf(7f to 7f, 7f to 16f, 16f to 16f, 17f to 7f)) {
            assertEquals(Color.White, sample(x, y), "Tile interior at ($x,$y) must stay hollow")
        }
        assertEquals(Color.Black, sample(3.75f, 7f), "Left outline must remain visible")
        assertEquals(Color.Black, sample(7f, 20.25f), "Bottom outline must remain visible")
    }
}
