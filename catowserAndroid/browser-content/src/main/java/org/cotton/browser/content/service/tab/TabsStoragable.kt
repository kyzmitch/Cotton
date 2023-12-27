package org.cotton.browser.content.service.tab

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query
import androidx.room.Update
import org.cotton.browser.content.data.Tab
import java.util.UUID

@Dao
interface TabsStoragable {
    /**
     *  The identifier of selected tab.
     * */
    @Query("SELECT selected_tab_id FROM app_settings LIMIT 1")
    @Throws(Exception::class)
    fun fetchSelectedTabId(): UUID
    /**
     *  Changes selected tab only if it is presented in storage.
     *
     *  @param tabId A tab which needs to be selected, if there is another tab
     *  which was selected before it is deselected.
     * */
    @Update(entity = AppSettings::class)
    @Throws(Exception::class)
    fun select(tabId: UUID)
    /**
     * Loads tabs data from storage.
     *
     * @return All the tabs for the current user account.
     * */
    @Query("SELECT * FROM tabs ORDER BY added_timestamp DESC")
    @Throws(Exception::class)
    fun fetchAllTabs(): List<Tab>
    /**
     *  Adds a tab to storage
     *
     *  @param tab The tab object to be updated. Usually only tab content needs to be updated.
     * */
    @Insert(entity = Tab::class)
    @Throws(Exception::class)
    fun add(tab: Tab)
    /**
     * Updates tab content
     *
     * @param tab The tab object to be updated. Usually only tab content needs to be updated.
     * */
    @Update(entity = Tab::class)
    @Throws(Exception::class)
    suspend fun update(tab: Tab)
    /**
     * Removes some tabs for current session
     *
     * @param tabs Remove one or more tabs
     * */
    @Query("DELETE FROM tabs WHERE id in (:tabs)")
    @Throws(Exception::class)
    suspend fun remove(tabs: List<UUID>)
}
