package org.cotton.browser.content.usecase

import org.cotton.browser.content.data.Tab
import org.cotton.browser.content.data.tab.ContentType

/**
 * Write tabs api use case,
 * some methods are from former `TabsSubject` interface in observer pattern.
 * */
interface WriteTabsUseCase {
    suspend fun add(tab: Tab)
    suspend fun close(tab: Tab)
    suspend fun closeAll()
    suspend fun select(tab: Tab)
    suspend fun replaceSelected(content: ContentType)
}