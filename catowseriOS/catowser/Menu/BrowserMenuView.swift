//
//  BrowserMenuView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 5/25/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import SwiftUI
import CottonBase
import CoreBrowser
import FeaturesFlagsKit

struct BrowserMenuView: View {
    @ObservedObject private var model: MenuViewModel
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - State variables to be able to pop view automatically
    
    @State private var isShowingAddTabSetting = false
    @State private var isShowingAppAsyncApiSetting = false
    @State private var isShowingDefaultTabContentSetting = false
    @State private var isShowingWebAutoCompleteSetting = false
    @State private var isShowingAppUIFrameworkSetting = false
    @State private var showingAppRestartAlert = false
    
    // MARK: - Allow to update text view content dynamically
    
    @State private var tabContentRowValue = FeatureManager.shared.tabDefaultContentValue()
    @State private var webAutocompleteRowValue = FeatureManager.shared.webSearchAutoCompleteValue()
    @State private var tabAddPositionRowValue = FeatureManager.shared.tabAddPositionValue()
    @State private var asyncApiRowValue = FeatureManager.shared.appAsyncApiTypeValue()
    @State private var uiFrameworkRowValue = FeatureManager.shared.appUIFrameworkValue()
    
    init(_ vm: MenuViewModel) {
        self.model = vm
    }
    
    var body: some View {
        NavigationView {
            List {
                if case .withSiteMenu = model.style {
                    Section(header: Text(model.siteSectionTitle)) {
                        Toggle(isOn: $model.isTabJSEnabled) {
                            Text(.jsMenuTitle)
                        }
                    }
                }
                Section(header: Text(.globalSectionTtl)) {
                    Toggle(isOn: $model.isDohEnabled) {
                        Text(.dohMenuTitle)
                    }
                    Toggle(isOn: $model.isJavaScriptEnabled) {
                        Text(.jsMenuTitle)
                    }
                    NavigationLink(destination: BaseMenuView<AddedTabPosition>(model: .init { (selected) in
                        FeatureManager.shared.setFeature(.tabAddPosition, value: selected)
                        self.isShowingAddTabSetting = false
                        tabAddPositionRowValue = selected
                    }), isActive: $isShowingAddTabSetting) {
                        Text(.tabAddTxt)
                        Spacer()
                        Text(verbatim: tabAddPositionRowValue.description).alignRight()
                    }
                    NavigationLink(destination: BaseMenuView<TabContentDefaultState>(model: .init { (selected) in
                        FeatureManager.shared.setFeature(.tabDefaultContent, value: selected)
                        self.isShowingDefaultTabContentSetting = false
                        tabContentRowValue = selected
                    }), isActive: $isShowingDefaultTabContentSetting) {
                        Text(.tabContentTxt)
                        Spacer()
                        Text(verbatim: tabContentRowValue.description).alignRight()
                    }
                }
                Section(header: Text(.searchSectionTtl)) {
                    NavigationLink(destination: BaseMenuView<WebAutoCompletionSource>(model: .init { (selected) in
                        FeatureManager.shared.setFeature(.webAutoCompletionSource, value: selected)
                        self.isShowingWebAutoCompleteSetting = false
                        webAutocompleteRowValue = selected
                    }), isActive: $isShowingWebAutoCompleteSetting) {
                        Text(.webAutoCompleteSourceTxt)
                        Spacer()
                        Text(verbatim: webAutocompleteRowValue.description).alignRight()
                    }
                }
#if DEBUG
                Section(header: Text(.devSectionTtl)) {
                    Toggle(isOn: $model.nativeAppRedirectEnabled) {
                        Text(.nativeAppRedirectTitle)
                    }
                    NavigationLink(destination: BaseMenuView<AsyncApiType>(model: .init { (selected) in
                        FeatureManager.shared.setFeature(.appDefaultAsyncApi, value: selected)
                        self.isShowingAppAsyncApiSetting = false
                        asyncApiRowValue = selected
                    }), isActive: $isShowingAppAsyncApiSetting) {
                        Text(.appAsyncApiTypeTxt)
                        Spacer()
                        Text(verbatim: asyncApiRowValue.description).alignRight()
                    }
                    NavigationLink(destination: BaseMenuView<UIFrameworkType>(model: .init { (selected) in
                        FeatureManager.shared.setFeature(.appDefaultUIFramework, value: selected)
                        self.isShowingAppUIFrameworkSetting = false
                        uiFrameworkRowValue = selected
                        self.showingAppRestartAlert.toggle()
                    }), isActive: $isShowingAppUIFrameworkSetting) {
                        Text(.appUIFrameworkTypeTxt)
                        Spacer()
                        Text(verbatim: uiFrameworkRowValue.description).alignRight()
                    }
                    Button("Simulate download resources") {
                        // Need to dismiss menu popover first if on Tablet
                        presentationMode.wrappedValue.dismiss()
                        model.emulateLinkTags()
                    }
                }
#endif
            }
            .navigationBarTitle(Text(verbatim: model.viewTitle))
            .navigationBarItems(trailing: Button<Text>(.dismissBtn) {
                presentationMode.wrappedValue.dismiss()
            }.foregroundColor(.black))
        }.alert(isPresented: $showingAppRestartAlert) {
            Alert(title: Text(verbatim: "App restart is required"), dismissButton: .destructive(Text(verbatim: "Kill app process")) {
                exit(0) // https://stackoverflow.com/a/8491688
            })
        }

    }
}

private extension Text {
    func alignRight() -> some View {
        self.frame(maxWidth: .infinity, alignment: .trailing)
            .multilineTextAlignment(.trailing)
    }
}

private extension LocalizedStringKey {
    static let globalSectionTtl: LocalizedStringKey = "ttl_global_menu"
    static let searchSectionTtl: LocalizedStringKey = "ttl_search_menu"
    static let devSectionTtl: LocalizedStringKey = "ttl_developer_menu"
    static let dohMenuTitle: LocalizedStringKey = "txt_doh_menu_item"
    static let jsMenuTitle: LocalizedStringKey = "txt_javascript_enabled"
    static let nativeAppRedirectTitle: LocalizedStringKey = "txt_native_app_redirect_enabled"
    static let dismissBtn: LocalizedStringKey = "btn_dismiss"
    static let tabAddTxt: LocalizedStringKey = "ttl_tab_positions"
    static let tabContentTxt: LocalizedStringKey = "ttl_tab_default_content"
    static let appAsyncApiTypeTxt: LocalizedStringKey = "ttl_app_async_method"
    static let webAutoCompleteSourceTxt: LocalizedStringKey = "ttl_web_search_auto_complete_source"
    static let appUIFrameworkTypeTxt: LocalizedStringKey = "ttl_app_ui_framework_type"
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
