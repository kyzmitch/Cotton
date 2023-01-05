//
//  WebViewController+Reusable.swift
//  catowser
//
//  Created by Andrei Ermoshin on 1/4/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import CoreHttpKit

/// A special case web view interface only for SwiftUI
/// because we have to reuse existing web view for all the tabs
protocol WebViewReusable: AnyObject {
    func resetTo(_ site: Site) -> Bool
}

extension WebViewController: WebViewReusable {
    func resetTo(_ site: Site) -> Bool {
        // Avoid calls to site load method when it is caused
        // by unexpected `updateUIViewController`
        guard viewModel.isResetable && viewModel.urlInfo != site.urlInfo else {
            return false
        }
        return viewModel.load(site)
    }
}
