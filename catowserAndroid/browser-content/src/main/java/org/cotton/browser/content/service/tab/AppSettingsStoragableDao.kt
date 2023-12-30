package org.cotton.browser.content.service.tab

import androidx.room.Dao
import androidx.room.Query
import androidx.room.Update
import java.util.UUID

@Dao
interface AppSettingsStoragableDao {
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
    @Query("UPDATE app_settings SET selected_tab_id = :tabId")
    @Throws(Exception::class)
    fun select(tabId: UUID)
}