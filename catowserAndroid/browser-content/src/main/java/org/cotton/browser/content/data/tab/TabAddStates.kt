package org.cotton.browser.content.data.tab

import android.icu.util.DateInterval

enum class AddedTabPosition {
    LIST_END,
    AFTER_SELECTED,
    ;
}

sealed class TabAddSpeed {
    data object Immediately : TabAddSpeed()
    class After(val interval: DateInterval) : TabAddSpeed()
}