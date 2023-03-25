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
    private weak var coordinator: C?
    
    init(_ coordinator: C?) {
        self.coordinator = coordinator
    }
    
    var body: some View {
        _MainBrowserView<C>(coordinator)
            .environment(\.browserContentCoordinators, coordinator)
    }
}

private struct _MainBrowserView<C: BrowserContentCoordinators>: View {
    private weak var coordinator: C?
    private let mode: SwiftUIMode
    
    init(_ coordinator: C?) {
        self.coordinator = coordinator
        mode = FeatureManager.appUIFrameworkValue().swiftUIMode
    }
    
    var body: some View {
        if isPad {
            TabletView(coordinator, mode)
        } else {
            PhoneView(coordinator, mode)
        }
    }
}
