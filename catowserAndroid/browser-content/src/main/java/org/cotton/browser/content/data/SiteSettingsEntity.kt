package org.cotton.browser.content.data

import androidx.room.ColumnInfo
import androidx.room.Entity
import org.cotton.base.Site

/**
 * Site.Settings wrapper for DB, because original Site.Settings type is in different framework.
 * Hoping that corresponding Site is linked with settings record to not store site/tab id.
 * */
@Entity(tableName = "site_settings")
data class SiteSettingsEntity(private val value: Site.Settings) {
    @ColumnInfo(name = "block_popups")
    val blockPopups: Boolean = value.blockPopups
    @ColumnInfo(name = "can_load_plugins")
    val canLoadPlugins: Boolean = value.canLoadPlugins
    @ColumnInfo(name = "is_js_enabled")
    val isJsEnabled: Boolean = value.isJSEnabled
    @ColumnInfo(name = "is_private")
    val isPrivate: Boolean = value.isPrivate
}