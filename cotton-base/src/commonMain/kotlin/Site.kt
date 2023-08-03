package org.cotton.base

/**
 * IMPORTANT: Site type shouldn't mutate, on Swift language level it is required to be Sendable.
 *
 * @property urlInfo An initial URL
 * @property faviconData Used by top sites by loading high quality image from the Assets
 * @property searchSuggestion String associated with site if site was created from search engine.
 * This convenient property to transfer/save search query to use it for search view.
 * Different approach could be to store it in tab content type `.site` state as 2nd associated value.
 * */
class Site(
    val urlInfo: URLInfo,
    val settings: Settings,
    internal val faviconData: ByteArray? = null,
    val searchSuggestion: String? = null,
    val userSpecifiedTitle: String? = null
) {
    /*
    * Allows static properties or functions
    * */
    companion object

    val host: Host
        get() = urlInfo.host()

    val title: String
        get() {
            if (searchSuggestion != null) {
                return searchSuggestion
            } else if (userSpecifiedTitle != null) {
                return userSpecifiedTitle
            } else {
                return urlInfo.domainName.rawString
            }
        }

    val searchBarContent: String
        get() = searchSuggestion ?: urlInfo.urlWithoutPort

    /**
     * Site settings.
     * */
    data class Settings(
        val isPrivate: Boolean = false,
        val blockPopups: Boolean = true,
        val isJSEnabled: Boolean = true,
        val canLoadPlugins: Boolean = true
    ) {
        fun withChanged(javaScriptEnabled: Boolean): Settings {
            return Settings(isPrivate, blockPopups, javaScriptEnabled, canLoadPlugins)
        }

        override fun equals(other: Any?): Boolean {
            if (this === other) return true
            other as Settings
            return isPrivate == other.isPrivate &&
                blockPopups == other.blockPopups &&
                isJSEnabled == other.isJSEnabled &&
                canLoadPlugins == other.canLoadPlugins
        }
    }

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        other as Site
        return urlInfo == other.urlInfo &&
            settings == other.settings &&
            searchSuggestion == other.searchSuggestion &&
            userSpecifiedTitle == other.userSpecifiedTitle &&
            faviconData == other.faviconData
    }
}

expect class Image

expect fun Site.withFavicon(image: Image): Site?
expect fun Site.favicon(): Image?
