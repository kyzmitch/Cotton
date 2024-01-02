package org.cotton.browser.content.data.tab

import android.icu.util.DateInterval

sealed class TabAddSpeed {
    data object Immediately : TabAddSpeed()
    class After(val interval: DateInterval) : TabAddSpeed()
}