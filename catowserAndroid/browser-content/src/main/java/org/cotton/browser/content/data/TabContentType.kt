package org.cotton.browser.content.data

import org.cotton.base.Site

sealed class TabContentType {
    companion object {
        fun createFrom(rawValue: Int, site: Site? = null): TabContentType {
            return when (rawValue) {
                0 -> Blank()
                1 -> site?.let { return@let SiteContent(it) } ?: Blank()
                2 -> Homepage()
                3 -> Favorites()
                4 -> TopSites()
                else -> Blank()
            }
        }
    }

    class Blank() : TabContentType()
    class TopSites() : TabContentType()
    class Favorites() : TabContentType()
    class Homepage() : TabContentType()
    class SiteContent(val site: Site) : TabContentType()

    val title: String
        get() {
            return when (this) {
                is Blank -> String.defaultTitle
                is TopSites -> String.topSitesTitle
                is SiteContent -> this.site.title
                else -> "Not implemented"
            }
        }

    val searchBarContent: String
        get() {
            return when (this) {
                is SiteContent -> this.site.searchBarContent
                else -> ""
            }
        }

    val rawValue: Int
        get() {
            return when(this) {
                is Blank -> 0
                is SiteContent -> 1
                is Homepage -> 2
                is Favorites -> 3
                is TopSites -> 4
            }
        }

    val isStatic: Boolean get() = !(this is SiteContent)
}

/// "ttl_tab_short_blank"
val String.Companion.defaultTitle: String get() = "Blank"
/// "ttl_tab_short_top_sites"
val String.Companion.topSitesTitle: String get() = "Top sites"