package org.cotton.browser.content.service.tab

/**
 * A Tab selection strategy (Compositor) defines the algorithms of tab selection in specific cases:
 * - when tab was removed and need to select another
 *
 * */
interface TabSelectionStrategy {
    /**
     * Computes the new index for the currently selected tab when that tab is removed
     *
     * @param context An index selection context, usually the tabs list manager
     * @param removedIndex The index which was removed
     * @return computed new index of the tab which needs to be selected
     * */
    suspend fun autoSelectedIndexAfterTabRemove(context: IndexSelectionContext, removedIndex: Int): Int
    /**
     * Tells if the app needs to select the new tab after it is added
     * */
    val makeTabActiveAfterAdding: Boolean
}