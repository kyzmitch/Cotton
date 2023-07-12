package org.cotton.browser.content.state

import org.cotton.base.Site

sealed class TopSitesUiState {
    class Loading() : TopSitesUiState()
    class Ready(val sites: List<Site>) : TopSitesUiState()

    internal val title: String
        get() {
            return when (this) {
                is Loading -> "Loading top sites"
                is Ready -> "Top sites: " + sites.toString
            }
        }
}

internal val List<Site>.toString: String
    get() {
        var result = ""
        for (site in this) {
            result += site.title + ", "
        }
        return result.dropLast(2)
    }