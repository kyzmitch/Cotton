package org.cotton.browser.content.service.tab

/**
 * An index selection context for the tab selection strategy.
 * Have to use function instead of a property when need to be in
 * async context.
 * */
interface IndexSelectionContext {
    val collectionLastIndex: Int
    suspend fun currentlySelectedIndex(): Int
}
