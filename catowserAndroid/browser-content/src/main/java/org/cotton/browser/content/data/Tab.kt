package org.cotton.browser.content.data

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.Index
import androidx.room.PrimaryKey
import org.cotton.browser.content.data.site.SiteEntity
import org.cotton.browser.content.data.site.roomEntity
import org.cotton.browser.content.data.tab.ContentType
import java.util.Date
import java.util.UUID

@Entity(
    tableName = "tabs",
    indices = [Index("id")]
)
data class Tab(private val data: Triple<ContentType, UUID, Date>) {
    constructor(
        contentType: ContentType,
        identifier: UUID = UUID.randomUUID(),
        created: Date = Date())
            : this(Triple(contentType, identifier, created))

    companion object {
        val blank: Tab get() = Tab(ContentType.Blank)
    }

    @PrimaryKey
    val id: UUID = data.second
    @ColumnInfo(name = "content_type_raw_value")
    val contentTypeRawValue: Int = data.first.rawValue
    @ColumnInfo(name = "added_timestamp")
    val addedTimestamp: Date = data.third
    @ColumnInfo(name = "site")
    val site: SiteEntity? = (data.first as? ContentType.SiteContent)?.site?.roomEntity()

    val contentType: ContentType
        get() {
            return ContentType.createFrom(contentTypeRawValue, site?.value)
        }
    val title: String get() = contentType.title
    val searchBarContent: String get() = contentType.searchBarContent
    fun isSelected(otherId: UUID): Boolean {
        return data.second == otherId
    }
}
