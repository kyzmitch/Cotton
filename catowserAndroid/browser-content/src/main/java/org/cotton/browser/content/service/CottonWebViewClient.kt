package org.cotton.browser.content.service

import android.content.Intent
import android.graphics.Bitmap
import android.net.Uri
import android.util.Log
import android.webkit.WebView
import com.google.accompanist.web.AccompanistWebViewClient

class CottonWebViewClient : AccompanistWebViewClient() {
    override fun onPageStarted(view: WebView?, url: String?, favicon: Bitmap?) {
        super.onPageStarted(view, url, favicon)
        Log.d("Accompanist WebView", "Page started loading for $url")
    }

    override fun shouldOverrideUrlLoading(view: WebView?, url: String?): Boolean {
        if (Uri.parse(url).host == "instagram.com") {
            // This is a host which needs to be handled in web view
            // even if there is an app for it, to allow downloads
            return false
        }
        // so launch another Activity that handles URLs
        Intent(Intent.ACTION_VIEW, Uri.parse(url)).apply {
            // Some activity could be started after that
            // by calling something like `startActivity(this)`
        }
        return true
    }
}