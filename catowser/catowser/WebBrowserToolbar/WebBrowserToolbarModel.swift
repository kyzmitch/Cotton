//
//  WebBrowserToolbarModel.swift
//  catowser
//
//  Created by Andrey Ermoshin on 03.01.2023.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import SwiftUI

final class WebBrowserToolbarModel: ObservableObject {
    @Published var webViewInterface: WebViewNavigatable?
    
    init() {
        webViewInterface = nil
    }
}

extension WebBrowserToolbarModel: WebViewCreationObserver {
    func webViewInterfaceDidChange(_ interface: WebViewNavigatable) {
        webViewInterface = interface
    }
}
