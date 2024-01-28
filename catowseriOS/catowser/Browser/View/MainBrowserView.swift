//
//  MainBrowserView.swift
//  catowser
//
//  Created by Andrey Ermoshin on 10.12.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import SwiftUI
import CoreBrowser
import CottonData

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
    @StateObject private var viewModel: MainBrowserViewModel<C>
    /// Browser content view model
    @StateObject private var browserContentVM: BrowserContentViewModel
    /// if User changes it in dev settings, then it is required to restart the app.
    /// Some other old code paths (coordinators and UIKit views) depend on that value,
    /// so, if new value is selected in dev menu, then it could create bugs if app is not restarted.
    /// At the moment app will crash if User selects new UI mode.
    private let mode: SwiftUIMode
    /// All tabs view model which can be injected only in async way, so, has to pass it from outside
    @ObservedObject private var allTabsVM: AllTabsViewModel
    /// Top sites view model has async dependencies and has to be injected
    @ObservedObject private var topSitesVM: TopSitesViewModel
    /// Search suggestions view model has async dependencies and has to be injected
    private let searchSuggestionsVM: SearchSuggestionsViewModel
    /// Web view model without a specific site
    private let webVM: any WebViewModel
    
    init(_ coordinatorsInterface: C,
         _ uiFrameworkType: UIFrameworkType,
         _ defaultContentType: Tab.ContentType,
         _ allTabsVM: AllTabsViewModel,
         _ topSitesVM: TopSitesViewModel,
         _ searchSuggestionsVM: SearchSuggestionsViewModel,
         _ webVM: any WebViewModel) {
        let mainVM = MainBrowserViewModel(coordinatorsInterface)
        _viewModel = StateObject(wrappedValue: mainVM)
        let browserVM = BrowserContentViewModel(mainVM.jsPluginsBuilder, defaultContentType)
        _browserContentVM = StateObject(wrappedValue: browserVM)
        mode = uiFrameworkType.swiftUIMode
        self.allTabsVM = allTabsVM
        self.topSitesVM = topSitesVM
        self.searchSuggestionsVM = searchSuggestionsVM
        self.webVM = webVM
    }
    
    var body: some View {
        Group {
            if isPad {
                TabletView(browserContentVM,
                           mode,
                           .blank,
                           allTabsVM,
                           topSitesVM,
                           searchSuggestionsVM,
                           webVM)
            } else {
                PhoneView(browserContentVM, 
                          mode,
                          topSitesVM,
                          searchSuggestionsVM,
                          webVM)
            }
        }
        .environment(\.browserContentCoordinators, viewModel.coordinatorsInterface)
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
