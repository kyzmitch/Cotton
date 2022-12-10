//
//  BrowserMenuView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 5/25/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

#if canImport(SwiftUI)
import SwiftUI
#endif
import CoreHttpKit
import CoreBrowser
import FeaturesFlagsKit

@available(iOS 13.0, *)
struct BrowserMenuView: View {
    let model: MenuViewModel
    var body: some View {
        _BrowserMenuView().environmentObject(model)
    }
}

@available(iOS 13.0, *)
private struct _BrowserMenuView: View {
    @EnvironmentObject var model: MenuViewModel
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - State variables to be able to pop view automatically
    
    @State private var isShowingAddTabSetting = false
    @State private var isShowingAppAsyncApiSetting = false
    @State private var isShowingDefaultTabContentSetting = false
    @State private var isShowingWebAutoCompleteSetting = false
    
    // MARK: - Allow to update text view content dynamically
    
    @State private var tabContentRowValueText = FeatureManager.tabDefaultContentValue().description
    @State private var webAutocompleteRowValueText = FeatureManager.webSearchAutoCompleteValue().description
    @State private var tabAddPositionRowValueText = FeatureManager.tabAddPositionValue().description
    @State private var asyncApiRowValueText = FeatureManager.appAsyncApiTypeValue().description
    
    var body: some View {
        NavigationView {
            List {
                if case .withSiteMenu = model.style {
                    Section(header: Text(model.siteSectionTitle)) {
                        Toggle(isOn: $model.isTabJSEnabled) {
                            Text(verbatim: .jsMenuTitle)
                        }
                    }
                }
                Section(header: Text(verbatim: .globalSectionTtl)) {
                    Toggle(isOn: $model.isDohEnabled) {
                        Text(verbatim: .dohMenuTitle)
                    }
                    Toggle(isOn: $model.isJavaScriptEnabled) {
                        Text(verbatim: .jsMenuTitle)
                    }
                    NavigationLink(destination: BaseMenuView<AddedTabPosition>(model: .init { (selected) in
                        FeatureManager.setFeature(.tabAddPosition, value: selected)
                        self.isShowingAddTabSetting = false
                        tabAddPositionRowValueText = selected.description
                    }), isActive: $isShowingAddTabSetting) {
                        Text(verbatim: .tabAddTxt)
                        Spacer()
                        Text(verbatim: tabAddPositionRowValueText)
                    }
                    NavigationLink(destination: BaseMenuView<TabContentDefaultState>(model: .init { (selected) in
                        FeatureManager.setFeature(.tabDefaultContent, value: selected)
                        self.isShowingDefaultTabContentSetting = false
                        tabContentRowValueText = selected.description
                    }), isActive: $isShowingDefaultTabContentSetting) {
                        Text(verbatim: .tabContentTxt)
                        Spacer()
                        Text(verbatim: tabContentRowValueText)
                    }
                }
                Section(header: Text(verbatim: .searchSectionTtl)) {
                    NavigationLink(destination: BaseMenuView<WebAutoCompletionSource>(model: .init { (selected) in
                        FeatureManager.setFeature(.webAutoCompletionSource, value: selected)
                        self.isShowingWebAutoCompleteSetting = false
                        webAutocompleteRowValueText = selected.description
                    }), isActive: $isShowingWebAutoCompleteSetting) {
                        Text(verbatim: .webAutoCompleteSourceTxt)
                        Spacer()
                        Text(verbatim: webAutocompleteRowValueText)
                    }
                }
#if DEBUG
                Section(header: Text(verbatim: .devSectionTtl)) {
                    NavigationLink(destination: BaseMenuView<AsyncApiType>(model: .init { (selected) in
                        FeatureManager.setFeature(.appDefaultAsyncApi, value: selected)
                        self.isShowingAppAsyncApiSetting = false
                        asyncApiRowValueText = selected.description
                    }), isActive: $isShowingAppAsyncApiSetting) {
                        Text(verbatim: .appAsyncApiTypeTxt)
                        Spacer()
                        Text(verbatim: asyncApiRowValueText)
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
            .navigationBarItems(trailing: Button<Text>(String.dismissBtn) {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

private extension String {
    static let globalSectionTtl = NSLocalizedString("ttl_global_menu", comment: "")
    static let searchSectionTtl = NSLocalizedString("ttl_search_menu", comment: "")
    static let devSectionTtl = NSLocalizedString("ttl_developer_menu", comment: "")
    static let dohMenuTitle = NSLocalizedString("txt_doh_menu_item",
                                                comment: "Title of DoH menu item")
    static let jsMenuTitle = NSLocalizedString("txt_javascript_enabled", comment: "")
    static let dismissBtn = NSLocalizedString("btn_dismiss",
                                              comment: "Button dismiss text")
    static let tabAddTxt = NSLocalizedString("ttl_tab_positions", comment: "Tab add setting text")
    static let tabContentTxt = NSLocalizedString("ttl_tab_default_content",
                                                 comment: "")
    static let appAsyncApiTypeTxt = NSLocalizedString("ttl_app_async_method",
                                                      comment: "")
    static let webAutoCompleteSourceTxt = NSLocalizedString("ttl_web_search_auto_complete_source",
                                                        comment: "")
}

#if DEBUG
// swiftlint:disable type_name
@available(iOS 13.0, *)
struct SiteMenuView_Previews: PreviewProvider {
    static var previews: some View {
        let host = try? Host(input: "example.com")
        let settings = Site.Settings(isPrivate: false,
                                     blockPopups: true,
                                     isJSEnabled: true,
                                     canLoadPlugins: true)
        // swiftlint:disable force_unwrapping
        let style: BrowserMenuStyle = .withSiteMenu(host!, settings)
        let model = MenuViewModel(style)
        return _BrowserMenuView().environmentObject(model)
    }
}
#endif
