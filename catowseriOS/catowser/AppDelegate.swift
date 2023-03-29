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

    /// Should be stored by strong reference, because it is the only owner of App coordinator
    private let appCoordinator: AppCoordinator = .init(ViewsEnvironment.shared.vcFactory)

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // This is to fix favicon.ico for Instagram site, calling it once
        // https://github.com/Alamofire/AlamofireImage/issues/378#issuecomment-537275604
        
        ImageResponseSerializer.addAcceptableImageContentTypes(["image/vnd.microsoft.icon", "application/octet-stream"])
        
        // Disable checks for SSL for favicons, but it doesn't work for some reason
        let config: URLSessionConfiguration = ImageDownloader.defaultURLSessionConfiguration()
        let serverTrustManager: ServerTrustManager = .init(allHostsMustBeEvaluated: false, evaluators: [:])
        let session = Session(configuration: config,
                              startRequestsImmediately: false,
                              serverTrustManager: serverTrustManager)
        UIImageView.af.sharedImageDownloader = ImageDownloader(session: session)
        
        appCoordinator.start()
        return true
    }
}

extension UIApplication {
    /// Resigns the keyboard.
    ///
    /// Used for resigning the keyboard when pressing the cancel button in a searchbar
    /// based on [this](https://stackoverflow.com/a/58473985/3687284) solution.
    /// - Parameter force: set true to resign the keyboard.
    func endEditing(_ force: Bool) {
        let windowScene = connectedScenes.first as? UIWindowScene
        // or use `isKeyWindow`
        let window = windowScene?.windows.first
        window?.endEditing(force)
    }
}