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
import HttpKit

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
    @State private var isShowingDefaultTabContentSetting = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text(model.siteSectionTitle)) {
                    Toggle(isOn: $model.isJavaScriptEnabled) {
                        Text(verbatim: .jsMenuTitle)
                    }
                }
                Section(header: Text(verbatim: .globalSectionTtl)) {
                    Toggle(isOn: $model.isDohEnabled) {
                        Text(verbatim: .dohMenuTitle)
                    }
                    NavigationLink(destination: TabAddPositionsView(model: .init { (selected) in
                        FeatureManager.setFeature(.tabAddPosition, value: selected.rawValue)
                        self.isShowingAddTabSetting = false
                    }), isActive: $isShowingAddTabSetting) {
                        Text(verbatim: .tabAddTxt)
                        Spacer()
                        Text(verbatim: model.currentTabAddValue)
                    }
                    NavigationLink(destination: TabDefaultContentView(model: .init { (selected) in
                        FeatureManager.setFeature(.tabDefaultContent, value: selected.rawValue)
                        self.isShowingDefaultTabContentSetting = false
                    }), isActive: $isShowingDefaultTabContentSetting) {
                        Text(verbatim: .tabContentTxt)
                        Spacer()
                        Text(verbatim: model.currentTabDefaultContent)
                    }
                }
            }
            .navigationBarTitle(Text(verbatim: model.viewTitle))
            .navigationBarItems(trailing: Button<Text>(String.dismissBtn, action: model.dismissAction))
        }
    }
}

private extension String {
    static let globalSectionTtl = NSLocalizedString("ttl_global_menu", comment: "")
    static let dohMenuTitle = NSLocalizedString("txt_doh_menu_item",
                                                comment: "Title of DoH menu item")
    static let jsMenuTitle = NSLocalizedString("txt_javascript_enabled_for_tab", comment: "")
    static let dismissBtn = NSLocalizedString("btn_dismiss",
                                              comment: "Button dismiss text")
    static let tabAddTxt = NSLocalizedString("ttl_tab_positions", comment: "Tab add setting text")
    static let tabContentTxt = NSLocalizedString("ttl_tab_default_content", comment: "")
}

#if DEBUG
// swiftlint:disable type_name
@available(iOS 13.0, *)
struct SiteMenuView_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable force_unwrapping
        let host = HttpKit.Host(rawValue: "example.com")!
        let model = SiteMenuModel(host: host, siteDelegate: nil) {
            print("Dismiss triggered")
        }
        return _SiteMenuView().environmentObject(model)
    }
}
#endif
