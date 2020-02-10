//
//  AppDelegate.swift
//  catowser
//
//  Created by admin on 11/06/2017.
//  Copyright © 2017 andreiermoshin. All rights reserved.
//

import UIKit
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let themeType: ThemeType = .default

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // This is to fix favicon.ico for Instagram site, calling it once
        DataRequest.addAcceptableImageContentTypes(["image/vnd.microsoft.icon"])
        
        let rect = CGRect(x: 0,
                          y: 0,
                          width: UIScreen.main.bounds.width,
                          height: UIScreen.main.bounds.height)
        window = UIWindow(frame: rect)
        let rootViewController = MasterBrowserViewController()
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
        
        return true
    }
}
