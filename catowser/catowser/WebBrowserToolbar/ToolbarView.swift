//
//  ToolbarView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 12/11/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import UIKit
import SwiftUI

struct ToolbarView: View {
    @ObservedObject var model: WebBrowserToolbarModel
    @Binding var webViewInterface: WebViewNavigatable?
    
    var body: some View {
        ToolbarLegacyView(webViewInterface: webViewInterface)
            .frame(height: CGFloat.toolbarViewHeight)
    }
}

private struct ToolbarLegacyView: UIViewControllerRepresentable {
    let webViewInterface: WebViewNavigatable?
    typealias UIViewControllerType = UIViewController
    
    private var vcFactory: ViewControllerFactory {
        ViewsEnvironment.shared.vcFactory
    }
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        let interface = context.environment.browserContentCoordinators
        let vc = vcFactory.toolbarViewController(nil,
                                                 interface?.globalMenuDelegate,
                                                 interface?.toolbarCoordinator,
                                                 interface?.toolbarPresenter)
        // TODO: set webViewInterface for toolbar view from view controller
        // swiftlint:disable:next force_unwrapping
        return vc!
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}
