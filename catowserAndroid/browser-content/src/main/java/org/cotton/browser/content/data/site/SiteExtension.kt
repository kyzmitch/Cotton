package org.cotton.browser.content.data.site

import org.cotton.base.DomainName
import org.cotton.base.HttpScheme
import org.cotton.base.Site
import org.cotton.base.URLInfo

internal val Site.Companion.opennetru: Site
    get() {
        val domain = DomainName("opennet.ru")
        val info = URLInfo(HttpScheme.HTTPS, "", null, domain)
        val settings = Site.Settings()
        return Site(info, settings)
    }

internal val Site.Companion.github: Site
    get() {
        val domain = DomainName("github.com")
        val info = URLInfo(HttpScheme.HTTPS, "", null, domain)
        val settings = Site.Settings()
        return Site(info, settings)
    }
