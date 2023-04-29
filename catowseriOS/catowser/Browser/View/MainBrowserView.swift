//
//  MainBrowserView.swift
//  catowser
//
//  Created by Andrey Ermoshin on 10.12.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import SwiftUI
import CoreBrowser
import FeaturesFlagsKit

enum SwiftUIMode {
    /// Re-uses UIKit views
    case compatible
    /// Only new SwiftUI views where possible, web view is still not present
    case full
}

extension UIFrameworkType {
    /// Converts to have only SwiftUI types
    var swiftUIMode: SwiftUIMode {
        switch self {
        case .uiKit:
            // This case is not possible
            // because different view controller is used
            assertionFailure("UIKit is selected in SwiftUI view")
            return .compatible
        case .swiftUIWrapper:
            return .compatible
        case .swiftUI:
            return .full
        }
    }
}

struct MainBrowserView<C: BrowserContentCoordinators>: View {
    private let vm: MainBrowserModel<C>
    ///
    @ObservedObject private var browserContentVM: BrowserContentViewModel
    /// if Developer changes it in dev settings, then it is required to restart the app.
    /// Some other old code (coordinators and UIKit views) depends on that value
    /// so, if new values is selected in dev menu, then it could create bugs if app is not restarted
    private let mode: SwiftUIMode
    
    init(_ vm: MainBrowserModel<C>) {
        self.vm = vm
        browserContentVM = .init(vm.jsPluginsBuilder)
        mode = FeatureManager.appUIFrameworkValue().swiftUIMode
    }
    
    var body: some View {
        Group {
            if isPad {
                TabletView(browserContentVM, mode)
            } else {
                PhoneView(browserContentVM, mode)
            }
        }
        .environment(\.browserContentCoordinators, vm.coordinatorsInterface)
    }
}
