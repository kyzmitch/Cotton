package org.cotton.browser.content

import androidx.lifecycle.ViewModel

class SearchBarViewModel: ViewModel() {
    val searchText: String = ""
    val placeholderText: String = "Search or enter address"
    val onSearchTextChanged: (String) -> Unit = {}
    val onClearClick: () -> Unit = {}
}