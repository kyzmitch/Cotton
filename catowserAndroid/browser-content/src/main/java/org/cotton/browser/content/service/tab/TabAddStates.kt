package org.cotton.browser.content.service.tab

import android.icu.util.DateInterval

enum class AddedTabPosition {
    LIST_END,
    AFTER_SELECTED,
    ;
}

sealed class TabAddSpeed {
    class Immediately() : TabAddSpeed()
    class After(val interval: DateInterval) : TabAddSpeed()
}