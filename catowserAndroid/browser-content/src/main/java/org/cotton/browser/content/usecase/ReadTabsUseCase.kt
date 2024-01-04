package org.cotton.browser.content.usecase

import org.cotton.browser.content.data.Tab
import java.util.UUID

/**
 * Read tabs api use case,
 * some methods are from former `TabsSubject` interface in observer pattern
 * */
interface ReadTabsUseCase {
    suspend fun tabsCount(): Int
    suspend fun selectedId(): UUID
    suspend fun allTabs(): List<Tab>
}
