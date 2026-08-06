//
//  WebViewController+Reusable.swift
//  catowser
//
//  Created by Andrei Ermoshin on 1/4/23.
//  Copyright © 2023 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import CottonBase

extension WebViewController: WebViewReusable {
    func resetTo(_ site: Site) {
        /// Avoid calls to site load method when it is caused by unexpected `updateUIViewController`
        guard viewModel.isResetable && viewModel.urlInfo != site.urlInfo else {
            return
        }
        viewModel.siteNavigation?.webViewDidHandleReuseAction()
        recreateWebView(true)
        reattachWebViewObservers()
        viewModel.sendAction(.openSite(site)) { result in
            if case .failure(let error) = result {
                print(error.localizedDescription)
            }
        }
    }
}
