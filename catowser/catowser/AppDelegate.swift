//
//  AppDelegate.swift
//  catowser
//
//  Created by admin on 11/06/2017.
//  Copyright © 2017 andreiermoshin. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        let rootViewController = MasterBrowserViewController()
        let viewModel = MasterBrowserViewModel()
        rootViewController.viewModel = viewModel
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
        
        return true
    }

}

