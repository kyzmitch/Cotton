package org.cotton.app.strategy

import org.cotton.browser.content.service.tab.IndexSelectionContext
import org.cotton.browser.content.service.tab.TabSelectionStrategy

/**
 * Implements the algorithms for the nearby use case
 * when the next closest tab needs to be selected.
 * */
class NearbySelectionStrategy
    constructor(override val makeTabActiveAfterAdding: Boolean = true): TabSelectionStrategy {
    override suspend fun autoSelectedIndexAfterTabRemove(context: IndexSelectionContext,
                                                         removedIndex: Int): Int {
        val value: Int
        val currentIx = context.currentlySelectedIndex()
        if (currentIx == removedIndex) {
            // find if we're closing selected tab
            // select next - same behaviour is in Firefox for ios
            if (removedIndex == context.collectionLastIndex) {
                value = removedIndex - 1
            } else {
                // if it is not last index, then it is automatically will become next index as planned
                // index is the same, but tab content will be different, so, need to notify observers
                // re-settings same value will trigger observers notification
                value = currentIx
            }
        } else {
            if (removedIndex < currentIx) {
                value = currentIx - 1
            } else {
                // for opposite case it will stay the same
                value = currentIx
            }
        }
        return value
    }
}
