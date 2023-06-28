package org.cotton.browser.content

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.material.LinearProgressIndicator
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.material.Text
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.google.accompanist.web.LoadingState
import com.google.accompanist.web.WebView
import com.google.accompanist.web.rememberWebViewNavigator
import com.google.accompanist.web.rememberWebViewState
import org.cotton.base.Site
import org.cotton.browser.content.service.CottonWebViewClient

@Composable
fun CottonWebView(site: Site) {
    val webClient = remember {
        CottonWebViewClient()
    }
    val navigator = rememberWebViewNavigator()
    val state = rememberWebViewState(url = site.urlInfo.urlWithoutPort)
    val loadingState = state.loadingState
    if (loadingState is LoadingState.Loading) {
        LinearProgressIndicator(
            progress = loadingState.progress,
            modifier = Modifier.fillMaxWidth()
        )
    }
    WebView(
        state = state,
        navigator = navigator,
        onCreated = { webView ->
            webView.settings.javaScriptEnabled = true
        },
        client = webClient
    )
}

@Preview
@Composable
private fun WebViewPreview() {
    Column {
        Text("Preview should still load but WebView will be grey box.")
        WebView(
            state = rememberWebViewState(url = "localhost"),
            modifier = Modifier.height(100.dp)
        )
    }
}