package org.cotton.browser.content

import androidx.lifecycle.ViewModel
import org.cotton.browser.content.usecase.ReadTabsUseCase
import org.cotton.browser.content.usecase.WriteTabsUseCase

class TabsListViewModel
    constructor(
        private val readTabsUseCase: ReadTabsUseCase,
        private val writeTabsUseCase: WriteTabsUseCase
    ): ViewModel() {

}