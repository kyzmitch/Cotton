//
//  WebViewController+Reusable.swift
//  catowser
//
//  Created by Andrei Ermoshin on 1/4/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import CottonCoreBaseKit

extension WebViewController: WebViewReusable {
    func resetTo(_ site: Site) {
        // Avoid calls to site load method when it is caused
        // by unexpected `updateUIViewController`
        guard viewModel.isResetable && viewModel.urlInfo != site.urlInfo else {
            return
        }
        externalNavigationDelegate?.webViewDidHandleReuseAction()
        viewModel.reset(site)
    }
}
