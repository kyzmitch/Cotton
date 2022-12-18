//
//  TopSitesView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 12/17/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import SwiftUI
import UIKit

struct TopSitesView: View {
    @EnvironmentObject var model: TopSitesModel
    
    var body: some View {
        TopSitesLegacyView()
            .environmentObject(model)
    }
}

/**
 https://www.hackingwithswift.com/books/ios-swiftui/wrapping-a-uiviewcontroller-in-a-swiftui-view
 https://developer.apple.com/documentation/swiftui/uiviewcontrollerrepresentable/
 https://www.hackingwithswift.com/books/ios-swiftui/using-coordinators-to-manage-swiftui-view-controllers
 
 */

private struct TopSitesLegacyView: UIViewControllerRepresentable {
    @EnvironmentObject var model: TopSitesModel
    typealias UIViewControllerType = UIViewController
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        let interface = context.environment.browserContentCoordinators
        let vc: AnyViewController & TopSitesInterface = ViewsEnvironment
            .shared
            .vcFactory
            .topSitesViewController(interface?.topSitesCoordinator)
        vc.reload(with: DefaultTabProvider.shared.topSites)
        return vc.viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}
