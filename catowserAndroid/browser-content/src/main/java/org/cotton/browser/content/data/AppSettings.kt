package org.cotton.browser.content.data

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey
import java.util.UUID

@Entity(tableName = "app_settings")
data class AppSettings(
    @ColumnInfo(name = "selected_tab_id") val selectedTabId: UUID
) {
    val selectedTabIdString: String get() = selectedTabId.toString()
    @PrimaryKey(autoGenerate = true)
    val id: Int = 113
}