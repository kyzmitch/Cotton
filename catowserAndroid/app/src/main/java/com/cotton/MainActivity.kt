package com.cotton

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.material.MaterialTheme
import androidx.compose.material.Surface
import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.cotton.ui.theme.CottonTheme
import com.browser.content.SearchBarView
import com.browser.content.BrowserContent
import com.browser.content.TabContentType
import org.cotton.base.DomainName
import org.cotton.base.HttpScheme
import org.cotton.base.Site
import org.cotton.base.URLInfo

class MainActivity : ComponentActivity() {
    private var searchText: String = ""
    private val onSearchTextChanged: (String) -> Unit = {}
    private val onClearClick: () -> Unit = {}
    private var matchesFound: Boolean = false
    private val results: @Composable () -> Unit = {}

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            CottonTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colors.background
                ) {
                    Box {
                        Column(
                            modifier = Modifier
                                .fillMaxSize()
                        ) {
                            SearchBarView(
                                searchText,
                                "Search or enter address",
                                onSearchTextChanged,
                                onClearClick
                            )
                            if (matchesFound) {
                                Text("Results", modifier = Modifier.padding(8.dp), fontWeight = FontWeight.Bold)
                                results()
                            } else {
                                val domain = DomainName("opennet.ru")
                                val info = URLInfo(HttpScheme.https, "", null, domain)
                                val settings = Site.Settings()
                                val site = Site(info, settings)
                                val content = TabContentType.SiteContent(site)
                                BrowserContent(contentType = content)
                            }
                        } // column
                    } // box
                } // surface
            } // cotton theme
        }
    }
}
