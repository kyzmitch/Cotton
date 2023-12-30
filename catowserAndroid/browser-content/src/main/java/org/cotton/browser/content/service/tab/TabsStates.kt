package org.cotton.browser.content.service.tab

import org.cotton.browser.content.data.tab.AddedTabPosition
import org.cotton.browser.content.data.tab.ContentType
import org.cotton.browser.content.data.tab.TabAddSpeed
import java.util.UUID

interface TabsStates {
    val addPosition: AddedTabPosition
    val contentState: ContentType
    val addSpeed: TabAddSpeed
    val defaultSelectedTabId: UUID
}