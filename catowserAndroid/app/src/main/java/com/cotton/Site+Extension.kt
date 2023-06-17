package com.cotton

import org.cotton.base.DomainName
import org.cotton.base.HttpScheme
import org.cotton.base.Site
import org.cotton.base.URLInfo

internal val Site.Companion.opennetru: Site
    get() {
        val domain = DomainName("opennet.ru")
        val info = URLInfo(HttpScheme.https, "", null, domain)
        val settings = Site.Settings()
        return Site(info, settings)
    }
