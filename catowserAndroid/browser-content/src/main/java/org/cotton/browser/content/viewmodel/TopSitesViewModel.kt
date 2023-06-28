package org.cotton.browser.content.viewmodel

import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow

enum class TopSitesUiState {
    LOADING, READY
}

class TopSitesViewModel: ViewModel() {
    val uiState: Flow<TopSitesUiState> = uiStateStream()

    private fun uiStateStream(): Flow<TopSitesUiState> {
        flow<TopSitesUiState> {
            emit(TopSitesUiState.LOADING)
        }
    }
}