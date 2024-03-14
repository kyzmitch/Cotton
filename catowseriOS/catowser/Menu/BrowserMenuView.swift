//
//  BrowserMenuView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 5/25/20.
//  Copyright © 2020 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import SwiftUI
import CottonBase
import CoreBrowser
import FeaturesFlagsKit

struct BrowserMenuView: View {
    @ObservedObject private var model: MenuViewModel
    @Environment(\.presentationMode) var presentationMode

    // MARK: - State variables to be able to pop view automatically

    @State private var showingAppRestartAlert = false
    @State private var path: [CottonMenuItem] = []

    // MARK: - Allow to update text view content dynamically

    @State private var tabContentRowValue: TabContentDefaultState = .favorites
    @State private var webAutocompleteRowValue: WebAutoCompletionSource = .google
    @State private var tabAddPositionRowValue: AddedTabPosition = .afterSelected
    @State private var asyncApiRowValue: AsyncApiType = .asyncAwait
    @State private var uiFrameworkRowValue: UIFrameworkType = .uiKit

    init(_ vm: MenuViewModel) {
        self.model = vm
    }

    var body: some View {
        NavigationStack(path: $path) {
            List {
                if case .withSiteMenu = model.style {
                    Section(header: Text(model.siteSectionTitle)) {
                        Toggle(isOn: $model.isTabJSEnabled) {
                            Text(LocalizedStringKey(.jsMenuTitle))
                        }
                    }
                }
                Section(header: Text(LocalizedStringKey(.globalSectionTtl))) {
                    Toggle(isOn: $model.isDohEnabled) {
                        Text(LocalizedStringKey(.dohMenuTitle))
                    }
                    Toggle(isOn: $model.isJavaScriptEnabled) {
                        Text(LocalizedStringKey(.jsMenuTitle))
                    }
                    NavigationLink(value: CottonMenuItem.tabAddPosition) {
                        MenuStatefullLabelView(.tabAddTxt, tabAddPositionRowValue.description)
                    }
                    NavigationLink(value: CottonMenuItem.defaultTabContent) {
                        MenuStatefullLabelView(.tabContentTxt, tabContentRowValue.description)
                    }
                }
                Section(header: Text(LocalizedStringKey(.searchSectionTtl))) {
                    NavigationLink(value: CottonMenuItem.webAutocompletionSource) {
                        MenuStatefullLabelView(.webAutoCompleteSourceTxt, webAutocompleteRowValue.description)
                    }
                }
                #if DEBUG
                Section(header: Text(LocalizedStringKey(.devSectionTtl))) {
                    Toggle(isOn: $model.nativeAppRedirectEnabled) {
                        Text(LocalizedStringKey(.nativeAppRedirectTitle))
                    }
                    NavigationLink(value: CottonMenuItem.asyncApi) {
                        MenuStatefullLabelView(.appAsyncApiTypeTxt, asyncApiRowValue.description)
                    }
                    NavigationLink(value: CottonMenuItem.uiFramework) {
                        MenuStatefullLabelView(.appUIFrameworkTypeTxt, uiFrameworkRowValue.description)
                    }
                    Button("Simulate download resources") {
                        // Need to dismiss menu popover first if on Tablet
                        presentationMode.wrappedValue.dismiss()
                        model.emulateLinkTags()
                    }
                }
                #endif
            }
            .navigationDestination(for: CottonMenuItem.self, destination: { item in
                switch item {
                case .tabAddPosition:
                    BaseMenuView<AddedTabPosition>(viewModel: .init(tabAddPositionRowValue) { selected in
                        tabAddPositionRowValue = selected
                        model.setTabAddPosition(selected)
                        path = []
                    })
                case .defaultTabContent:
                    BaseMenuView<TabContentDefaultState>(viewModel: .init(tabContentRowValue) { selected in
                        tabContentRowValue = selected
                        model.setTabContent(selected)
                        path = []
                    })
                case .webAutocompletionSource:
                    BaseMenuView<WebAutoCompletionSource>(viewModel: .init(webAutocompleteRowValue) { selected in
                        webAutocompleteRowValue = selected
                        model.setAutocomplete(selected)
                        path = []
                    })
                case .asyncApi:
                    BaseMenuView<AsyncApiType>(viewModel: .init(asyncApiRowValue) { selected in
                        asyncApiRowValue = selected
                        model.setAsyncApi(selected)
                        path = []
                    })
                case .uiFramework:
                    BaseMenuView<UIFrameworkType>(viewModel: .init(uiFrameworkRowValue) { selected in
                        uiFrameworkRowValue = selected
                        showingAppRestartAlert.toggle()
                        model.setUiFramework(selected)
                        path = []
                    })
                }
            })
            .navigationBarTitle(Text(verbatim: model.viewTitle))
            .navigationBarItems(trailing: Button<Text>(LocalizedStringKey(.dismissBtn)) { presentationMode.wrappedValue.dismiss() }
            .foregroundColor(.black))
            .navigationDestination(for: CottonMenuItem.self) { menuItem in
                switch menuItem {
                case .tabAddPosition:
                    Text(LocalizedStringKey(.tabAddTxt))
                default:
                    Text("Not implemented")
                }
            }
        }
        .alert(isPresented: $showingAppRestartAlert) {
            Alert(title: Text(verbatim: "App restart is required"),
                  dismissButton: .destructive(Text(verbatim: "Kill app process")) {
                    exit(0) // https://stackoverflow.com/a/8491688
                  })
        }
        .task {
            tabContentRowValue = await FeatureManager.shared.tabDefaultContentValue()
            webAutocompleteRowValue = await FeatureManager.shared.webSearchAutoCompleteValue()
            tabAddPositionRowValue = await FeatureManager.shared.tabAddPositionValue()
            asyncApiRowValue = await FeatureManager.shared.appAsyncApiTypeValue()
            uiFrameworkRowValue = await FeatureManager.shared.appUIFrameworkValue()
        }
    }
}

#if DEBUG
struct SiteMenuView_Previews: PreviewProvider {
    static var previews: some View {
        let host = try? Host(input: "example.com")
        let settings = Site.Settings(isPrivate: false,
                                     blockPopups: true,
                                     isJSEnabled: true,
                                     canLoadPlugins: true)
        // swiftlint:disable force_unwrapping
        let style: BrowserMenuStyle = .withSiteMenu(host!, settings)
        let model = MenuViewModel(style, false, false, false)
        return BrowserMenuView(model)
    }
}
#endif
