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

@available(iOS 13.0.0, *)
struct SiteMenuView: View {
    let titleText = NSLocalizedString("ttl_site_menu", comment: "Menu for tab")
    let dohMenuTitle = NSLocalizedString("txt_doh_menu_item", comment: "Title of DoH menu item")
    
    @State var isDohEnabled = FeatureManager.boolValue(of: .dnsOverHTTPSAvailable)
    
    var body: some View {
        VStack {
            Text(titleText)
            List {
                Toggle(isOn: $isDohEnabled) {
                    Text(dohMenuTitle)
                }
            }
        }
    }
}

#if DEBUG
// swiftlint:disable type_name
@available(iOS 13.0.0, *)
struct SiteMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SiteMenuView()
    }
}
#endif
