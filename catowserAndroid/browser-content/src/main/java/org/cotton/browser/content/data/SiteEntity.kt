package org.cotton.browser.content.data

import androidx.room.ColumnInfo
import androidx.room.Entity
import org.cotton.base.Site

/**
 * Site type wrapper for DB, because original Site type is in different framework.
 * Hoping that it will be linked with corresponding Tab record to not store tab id.
 * */
@Entity(tableName = "sites")
data class SiteEntity(val value: Site) {
    @ColumnInfo(name = "search_suggestion")
    val searchSuggestion: String? = value.searchSuggestion
    @ColumnInfo(name = "site_url")
    val siteURL: String = value.urlInfo.urlWithoutPort
    @ColumnInfo(name = "user_specified_title")
    val userSpecifiedTitle: String? = value.userSpecifiedTitle
    @ColumnInfo(name = "ip_address")
    val ipAddress: String? = value.urlInfo.ipAddressString
    @ColumnInfo(name = "settings")
    val settings: SiteSettingsEntity = SiteSettingsEntity(value.settings)
}

fun Site.roomEntity(): SiteEntity {
    return SiteEntity(this)
}