package org.cotton.browser.content.data

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.Index
import androidx.room.PrimaryKey
import org.cotton.base.Site
import java.util.Date
import java.util.UUID

@Entity(
    tableName = "tabs",
    indices = [Index("id")]
)
data class Tab(private val data: Triple<TabContentType, UUID, Date>) {
    constructor(
        contentType: TabContentType,
        identifier: UUID = UUID.randomUUID(),
        created: Date = Date())
            : this(Triple(contentType, identifier, created))

    companion object {
        val blank: Tab get() = Tab(TabContentType.Blank())
    }

    @PrimaryKey
    val id: UUID = data.second
    @ColumnInfo(name = "content_type_raw_value")
    val contentTypeRawValue: Int = data.first.rawValue
    @ColumnInfo(name = "added_timestamp")
    val addedTimestamp: Date = data.third
    @ColumnInfo(name = "site")
    val site: SiteEntity? = (data.first as? TabContentType.SiteContent)?.site?.roomEntity()

    val contentType: TabContentType
        get() {
            return TabContentType.createFrom(contentTypeRawValue, site?.value)
        }
    val title: String get() = contentType.title
    val searchBarContent: String get() = contentType.searchBarContent
    fun isSelected(otherId: UUID): Boolean {
        return data.second == otherId
    }
}
