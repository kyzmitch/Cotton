package org.cotton.app.db

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.TypeConverters
import org.cotton.browser.content.data.ComplexDataConverters
import org.cotton.browser.content.data.Tab
import org.cotton.browser.content.service.tab.AppSettings
import org.cotton.browser.content.service.tab.AppSettingsStoragableDao
import org.cotton.browser.content.service.tab.TabsStoragableDao
import kotlin.concurrent.Volatile

/**
 * A database class which will auto-generate Dao implementations
 * for `TabsStoragable` and `AppSettingsStoragable`
 * */
@Database(
    entities = [Tab::class, AppSettings::class],
    version = 1,
    exportSchema = true
)
@TypeConverters(ComplexDataConverters::class)
abstract class TabsDBClient: RoomDatabase() {
    companion object {
        @Volatile
        private var shared: TabsDBClient? = null
        private val typeConverterInstance = ComplexDataConverters()

        fun getDatabase(context: Context): TabsDBClient {
            if (shared == null) {
                synchronized(this) {
                    shared = buildDatabase(context)
                }
            }
            return shared!!
        }

        private fun buildDatabase(context: Context): TabsDBClient {
            return Room
                .databaseBuilder(
                    context.applicationContext,
                    TabsDBClient::class.java,
                    "tabs_database"
                )
                .addTypeConverter(typeConverterInstance)
                .build()
        }
    }

    abstract fun tabsDao(): TabsStoragableDao
    abstract fun appSettingsDao(): AppSettingsStoragableDao
}