package dev.fluent2.core

import kotlin.test.*

class ContractsTest {
    @Test fun badgeHandlesOverflowAndRejectsInvalidCounts() {
        assertEquals("99+", formatFluentCount(100))
        assertEquals("999+", formatFluentCount(1000, 999))
        assertEquals("0", formatFluentCount(0))
        assertFailsWith<IllegalArgumentException> { formatFluentCount(-1) }
        assertFailsWith<IllegalArgumentException> { formatFluentCount(1, 0) }
    }
    @Test fun progressClampsFiniteValuesAndRejectsInvalidNumbers() {
        assertEquals(0f, normalizeFluentPercent(-10f))
        assertEquals(100f, normalizeFluentPercent(110f))
        assertFailsWith<IllegalArgumentException> { normalizeFluentPercent(Float.NaN) }
        assertFailsWith<IllegalArgumentException> { normalizeFluentPercent(Float.POSITIVE_INFINITY) }
    }
    @Test fun navigationSkipsDisabledValuesAndWraps() {
        val options = listOf(FluentOption(1, "One"), FluentOption(2, "Two", false), FluentOption(3, "Three"))
        assertEquals(2, nextEnabledOption(options, 0, 1))
        assertEquals(0, nextEnabledOption(options, 2, 1))
        assertEquals(2, nextEnabledOption(options, 0, -1))
        assertNull(nextEnabledOption(emptyList<FluentOption<Int>>(), 0, 1))
        assertNull(nextEnabledOption(listOf(FluentOption(1, "Disabled", false)), 0, 1))
        assertFailsWith<IllegalArgumentException> { validateOptions(listOf(FluentOption(1, "A"), FluentOption(1, "B"))) }
    }
}
