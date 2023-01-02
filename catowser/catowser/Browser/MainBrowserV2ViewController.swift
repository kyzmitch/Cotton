//
//  MainBrowserV2ViewController.swift
//  catowser
//
//  Created by Andrey Ermoshin on 10.12.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import UIKit
import SwiftUI

/**
 A replacement for the native SwiftUI starting point:
 
 @main
 struct CottonApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
 
     var body: some Scene {
         WindowGroup {
             MainBrowserView()
         }
     }
 }
 
 This allows to keep using UIKit views for now as a 2nd option.
 */

@available(iOS 13.0.0, *)
final class MainBrowserV2ViewController<C: Navigating & BrowserContentCoordinators>:
UIHostingController<MainBrowserView<C>> where C.R == MainScreenRoute {
    private weak var coordinator: C?

    init(_ coordinator: C) {
        self.coordinator = coordinator
        let model: MainBrowserModel<C> = .init(coordinator)
        let view = MainBrowserView(model: model)
        super.init(rootView: view)
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        coordinator?.stop()
    }
}
