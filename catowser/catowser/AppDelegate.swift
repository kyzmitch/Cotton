//
//  AppDelegate.swift
//  catowser
//
//  Created by admin on 11/06/2017.
//  Copyright © 2017 andreiermoshin. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let themeType: ThemeType = .default

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // This is to fix favicon.ico for Instagram site, calling it once
        // https://github.com/Alamofire/AlamofireImage/issues/378#issuecomment-537275604
        
        ImageResponseSerializer.addAcceptableImageContentTypes(["image/vnd.microsoft.icon", "application/octet-stream"])
        
        // Disable checks for SSL for favicons
        let config: URLSessionConfiguration = ImageDownloader.defaultURLSessionConfiguration()
        let serverTrustManager: ServerTrustManager = .init(allHostsMustBeEvaluated: false, evaluators: [:])
        let session = Session(configuration: config, startRequestsImmediately: false, serverTrustManager: serverTrustManager)
        UIImageView.af.sharedImageDownloader = ImageDownloader(session: session)
        
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
