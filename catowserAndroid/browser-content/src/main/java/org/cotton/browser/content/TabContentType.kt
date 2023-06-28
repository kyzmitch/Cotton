package org.cotton.browser.content

import org.cotton.base.Site

sealed class TabContentType {
    class Blank(): TabContentType()
    class TopSites(): TabContentType()
    class Favorites(): TabContentType()
    class Homepage(): TabContentType()
    class SiteContent(val site: Site): TabContentType()
}