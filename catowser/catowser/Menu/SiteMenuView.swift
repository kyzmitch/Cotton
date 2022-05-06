//
//  SiteMenuView.swift
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
struct SiteMenuView: View {
    let model: SiteMenuModel
    var body: some View {
        _SiteMenuView().environmentObject(model)
    }
}

@available(iOS 13.0, *)
private struct _SiteMenuView: View {
    @EnvironmentObject var model: SiteMenuModel
    @State private var isShowingAddTabSetting = false
    @State private var isShowingAppAsyncApiSetting = false
    @State private var isShowingDefaultTabContentSetting = false
    @State private var isShowingWebAutoCompleteSetting = false
    
    var body: some View {
        NavigationView {
            List {
                if model.host != nil {
                    Section(header: Text(model.siteSectionTitle)) {
                        Toggle(isOn: $model.isJavaScriptEnabled) {
                            Text(verbatim: .jsMenuTitle)
                        }
                    }
                }
                Section(header: Text(verbatim: .globalSectionTtl)) {
                    Toggle(isOn: $model.isDohEnabled) {
                        Text(verbatim: .dohMenuTitle)
                    }
                    NavigationLink(destination: BaseMenuView<AddedTabPosition>(model: .init { (selected) in
                        FeatureManager.setFeature(.tabAddPosition, value: selected)
                        self.isShowingAddTabSetting = false
                    }), isActive: $isShowingAddTabSetting) {
                        Text(verbatim: .tabAddTxt)
                        Spacer()
                        Text(verbatim: model.currentTabAddValue)
                    }
                    NavigationLink(destination: BaseMenuView<TabContentDefaultState>(model: .init { (selected) in
                        FeatureManager.setFeature(.tabDefaultContent, value: selected)
                        self.isShowingDefaultTabContentSetting = false
                    }), isActive: $isShowingDefaultTabContentSetting) {
                        Text(verbatim: .tabContentTxt)
                        Spacer()
                        Text(verbatim: model.currentTabDefaultContent)
                    }
                }
                Section(header: Text(verbatim: .searchSectionTtl)) {
                    NavigationLink(destination: BaseMenuView<WebAutoCompletionSource>(model: .init { (selected) in
                        FeatureManager.setFeature(.webAutoCompletionSource, value: selected)
                        self.isShowingWebAutoCompleteSetting = false
                    }), isActive: $isShowingWebAutoCompleteSetting) {
                        Text(verbatim: .webAutoCompleteSourceTxt)
                        Spacer()
                        Text(verbatim: model.selectedWebAutoCompleteStringValue)
                    }
                }
#if DEBUG
                Section(header: Text(verbatim: .devSectionTtl)) {
                    NavigationLink(destination: BaseMenuView<AsyncApiType>(model: .init { (selected) in
                        FeatureManager.setFeature(.appDefaultAsyncApi, value: selected)
                        self.isShowingAppAsyncApiSetting = false
                    }), isActive: $isShowingAppAsyncApiSetting) {
                        Text(verbatim: .appAsyncApiTypeTxt)
                        Spacer()
                        Text(verbatim: model.selectedAsyncApiStringValue)
                    }
                }
#endif
            }
            .navigationBarTitle(Text(verbatim: model.viewTitle))
            .navigationBarItems(trailing: Button<Text>(String.dismissBtn, action: model.dismissAction))
        }
    }
}

private extension String {
    static let globalSectionTtl = NSLocalizedString("ttl_global_menu", comment: "")
    static let searchSectionTtl = NSLocalizedString("ttl_search_menu", comment: "")
    static let devSectionTtl = NSLocalizedString("ttl_developer_menu", comment: "")
    static let dohMenuTitle = NSLocalizedString("txt_doh_menu_item",
                                                comment: "Title of DoH menu item")
    static let jsMenuTitle = NSLocalizedString("txt_javascript_enabled_for_tab", comment: "")
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
        let style: MenuModelStyle = .siteMenu(host: host!, siteSettings: settings)
        let model = SiteMenuModel(menuStyle: style,
                                  siteDelegate: nil) {
            print("Dismiss triggered")
        }
        return _SiteMenuView().environmentObject(model)
    }
}
#endif
