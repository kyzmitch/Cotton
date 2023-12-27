package org.cotton.browser.content.service.tab

import androidx.room.ColumnInfo
import androidx.room.Entity
import java.util.UUID

@Entity(tableName = "app_settings")
data class AppSettings(
    @ColumnInfo(name = "selected_tab_id") val selectedTabId: UUID
) {
    val selectedTabIdString: String get() = selectedTabId.toString()
}