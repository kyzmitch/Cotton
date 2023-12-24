package org.cotton.browser.content.service.tab

interface IndexSelectionContext {
    val collectionLastIndex: Int
    val currentlySelectedIndex: Int
}

interface TabSelectionStrategy {
    /**
     * A Tab selection strategy (Compositor) defines the algorithms of tab selection in specific cases
     * - when tab was removed and need to select another
     * */
    fun autoSelectedIndexAfterTabRemove(context: IndexSelectionContext, removedIndex: Int): Int
    val makeTabActiveAfterAdding: Boolean
}