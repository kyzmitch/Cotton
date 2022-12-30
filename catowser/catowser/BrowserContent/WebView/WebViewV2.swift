//
//  WebViewV2.swift
//  catowser
//
//  Created by Andrei Ermoshin on 12/19/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import SwiftUI

struct WebViewV2: View {
    @EnvironmentObject var model: WebViewSwiftUIModel
    
    var body: some View {
        WebViewLegacyView()
    }
}

private struct WebViewLegacyView: UIViewControllerRepresentable {
    @EnvironmentObject var model: WebViewSwiftUIModel
    typealias UIViewControllerType = UIViewController
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        // Usual coordinator can't really be used for SwiftUI navigation
        // but for the legacy view it has to be passed
        let dummyArgument: WebContentCoordinator? = nil
        let manager = ViewsEnvironment.shared.reuseManager
        let vc: (AnyViewController & WebViewNavigatable)? = try? manager.controllerFor(model.site,
                                                                                       model.jsPluginsBuilder,
                                                                                       model,
                                                                                       dummyArgument)
        // swiftlint:disable:next force_unwrapping
        return vc!.viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}
