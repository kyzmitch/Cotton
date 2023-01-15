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
    private let model: MainBrowserModel<C>
    
    init(_ model: MainBrowserModel<C>) {
        self.model = model
    }
    
    var body: some View {
        _MainBrowserView<C>(model: model)
            .environment(\.browserContentCoordinators, model.coordinatorsInterface)
    }
}

private struct _MainBrowserView<C: BrowserContentCoordinators>: View {
    private var model: MainBrowserModel<C>
    private let mode: SwiftUIMode
    
    init(model: MainBrowserModel<C>) {
        self.model = model
        mode = FeatureManager.appUIFrameworkValue().swiftUIMode
    }
    
    var body: some View {
        if isPad {
            TabletView(model, mode)
        } else {
            PhoneView(model, mode)
        }
    }
}
