package org.cotton.browser.content.service.tab

import org.cotton.browser.content.data.TabContentType
import java.util.UUID

interface TabsStates {
    val addPosition: AddedTabPosition
    val contentState: TabContentType
    val addSpeed: TabAddSpeed
    val defaultSelectedTabId: UUID
}