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

private extension String {
    static let menuTtl = NSLocalizedString("ttl_site_menu",
                                           comment: "Menu for tab")
    static let dohMenuTitle = NSLocalizedString("txt_doh_menu_item",
                                                comment: "Title of DoH menu item")
    static let dismissBtn = NSLocalizedString("btn_dismiss",
                                              comment: "Button dismiss text")
}

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
    
    private var viewTitle: String {
        return String.localizedStringWithFormat(.menuTtl, model.host.rawValue)
    }
    
    var body: some View {
        NavigationView {
            List {
                Toggle(isOn: $model.isDohEnabled) {
                    Text(verbatim: .dohMenuTitle)
                }
            }
            .navigationBarTitle(Text(verbatim: viewTitle))
            .navigationBarItems(trailing: Button<Text>(String.dismissBtn, action: model.dismissAction))
        }
    }
}

#if DEBUG
// swiftlint:disable type_name
@available(iOS 13.0, *)
struct SiteMenuView_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable force_unwrapping
        let host = HttpKit.Host(rawValue: "example.com")!
        let model = SiteMenuModel(host: host) {
            print("Dismiss triggered")
        }
        return _SiteMenuView().environmentObject(model)
    }
}
#endif
