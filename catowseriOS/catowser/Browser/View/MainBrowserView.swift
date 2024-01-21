//
//  MainBrowserView.swift
//  catowser
//
//  Created by Andrey Ermoshin on 10.12.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import SwiftUI
import CoreBrowser

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
    /// Store main view model in this main view to not have generic parameter in phone/tablet views
    private let vm: MainBrowserModel<C>
    /// Browser content view model
    @StateObject private var browserContentVM: BrowserContentViewModel
    /// if User changes it in dev settings, then it is required to restart the app.
    /// Some other old code paths (coordinators and UIKit views) depend on that value,
    /// so, if new value is selected in dev menu, then it could create bugs if app is not restarted.
    ///  At the moment app will crash if User selects new UI mode.
    private let mode: SwiftUIMode
    /// all tabs view model which can be injected only in async way, so, has to pass it from outside
    @ObservedObject private var allTabsVM: AllTabsViewModel
    
    init(_ vm: MainBrowserModel<C>, 
         _ uiFrameworkType: UIFrameworkType,
         _ defaultContentType: Tab.ContentType,
         _ allTabsVM: AllTabsViewModel) {
        self.vm = vm
        _browserContentVM = StateObject(wrappedValue: BrowserContentViewModel(vm.jsPluginsBuilder, defaultContentType))
        mode = uiFrameworkType.swiftUIMode
        self.allTabsVM = allTabsVM
    }
    
    var body: some View {
        Group {
            if isPad {
                TabletView(browserContentVM, mode, .blank, allTabsVM)
            } else {
                PhoneView(browserContentVM, mode)
            }
        }
        .environment(\.browserContentCoordinators, vm.coordinatorsInterface)
        .onAppear {
            Task {
                await TabsDataService.shared.attach(browserContentVM, notify: true)
            }
        }
        .onDisappear {
            Task {
                await TabsDataService.shared.detach(browserContentVM)
            }
        }
    }
}
