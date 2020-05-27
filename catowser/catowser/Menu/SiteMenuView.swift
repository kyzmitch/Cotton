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
extension UIHostingController where Content == SiteMenuView {
    static func create(siteMenu model: SiteMenuModel) -> UIHostingController {
        let menuView = SiteMenuView().environmentObject(model)
        // Can't be compiled for some reason
        // the view is opaque type and controller expects specific
        // view type (SiteMenuView or Content).
        // The very weird thing is that it compiles
        // outside this extension.
        #if false
        return UIHostingController(rootView: menuView)
        #else
        return UIHostingController(rootView: SiteMenuView())
        #endif
    }
}

@available(iOS 13.0.0, *)
final class SiteMenuViewController: UIHostingController<SiteMenuView> {
    init(model: SiteMenuModel) {
        let viewWithModel = SiteMenuView()
        // The problem is that this doesn't allow to set model
        // using `environmentObject` because it returns opaque View type
        // and for some strange reason it doens't compile here
        super.init(rootView: viewWithModel)
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@available(iOS 13.0.0, *)
struct SiteMenuView: View {
    let titleText = NSLocalizedString("ttl_site_menu", comment: "Menu for tab")
    let dohMenuTitle = NSLocalizedString("txt_doh_menu_item", comment: "Title of DoH menu item")
    
    @EnvironmentObject var model: SiteMenuModel
    
    var body: some View {
        NavigationView {
            List {
                Toggle(isOn: $model.isDohEnabled) {
                    Text(dohMenuTitle)
                }
            }
            .navigationBarTitle(Text(titleText))
            .navigationBarItems(trailing: Button<Text>("Dismiss", action: model.dismissAction))
        }
    }
}

#if DEBUG
// swiftlint:disable type_name
@available(iOS 13.0.0, *)
struct SiteMenuView_Previews: PreviewProvider {
    static var previews: some View {
        let model = SiteMenuModel {
            print("Dismiss triggered")
        }
        return SiteMenuView().environmentObject(model)
    }
}
#endif
