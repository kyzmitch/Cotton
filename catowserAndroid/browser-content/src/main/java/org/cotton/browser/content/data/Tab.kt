package org.cotton.browser.content.data

import org.cotton.base.Site
import java.util.Date
import java.util.UUID

@JvmInline
value class Tab(private val data: Triple<TabContentType, UUID, Date>) {
    constructor(
        contentType: TabContentType,
        identifier: UUID = UUID.randomUUID(),
        created: Date = Date())
            : this(Triple(contentType, identifier, created))

    companion object {
        val blank: Tab get() = Tab(TabContentType.Blank())
    }

    val contentType: TabContentType get() = data.first
    val id: UUID get() = data.second
    val addedTimestamp: Date get() = data.third

    val title: String get() = contentType.title
    val searchBarContent: String get() = contentType.searchBarContent
    val site: Site? get() = (contentType as? TabContentType.SiteContent)?.site
    fun isSelected(otherId: UUID): Boolean {
        return data.second == otherId
    }
}