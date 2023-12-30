package org.cotton.app.utils

import org.cotton.browser.content.data.tab.AddedTabPosition
import org.cotton.browser.content.data.tab.ContentType
import org.cotton.browser.content.data.tab.TabAddSpeed
import org.cotton.browser.content.service.tab.TabsStates
import java.util.UUID

class DefaultTabProvider : TabsStates {
    override val addPosition: AddedTabPosition = AddedTabPosition.AFTER_SELECTED
    override val contentState: ContentType = ContentType.TopSites
    override val addSpeed: TabAddSpeed = TabAddSpeed.Immediately
    override val defaultSelectedTabId: UUID = DefaultTab.notPossibleId
}

object DefaultTab {
    val notPossibleId: UUID by lazy {
        val bytes = ByteArray(4) {
            return@ByteArray when (it) {
                0 -> 0
                1 -> 255.toByte()
                2 -> 0
                3 -> 255.toByte()
                else -> 0
            }
        }
        UUID.nameUUIDFromBytes(bytes)
    }
}
