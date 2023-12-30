package org.cotton.browser.content.service.tab

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Update
import org.cotton.browser.content.data.Tab
import java.util.UUID

@Dao
interface TabsStoragableDao {
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
    @Insert(entity = Tab::class, onConflict = OnConflictStrategy.ABORT)
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
     * @param tabsIdentifiers Remove one or more tabs with specific identifiers
     * */
    @Query("DELETE FROM tabs WHERE id in (:tabsIdentifiers)")
    @Throws(Exception::class)
    suspend fun remove(tabsIdentifiers: List<UUID>)
}
