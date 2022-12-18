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

private struct CoordinatorsInterfaceKey: EnvironmentKey {
    static let defaultValue: CoordinatorsInterface? = nil
}

extension EnvironmentValues {
    /// For postponed coordinators init
    var coordinatorsInterface: CoordinatorsInterface? {
        get { self[CoordinatorsInterfaceKey.self] }
        set { self[CoordinatorsInterfaceKey.self] = newValue }
    }
}

/**
 https://www.hackingwithswift.com/books/ios-swiftui/wrapping-a-uiviewcontroller-in-a-swiftui-view
 https://developer.apple.com/documentation/swiftui/uiviewcontrollerrepresentable/
 https://www.hackingwithswift.com/books/ios-swiftui/using-coordinators-to-manage-swiftui-view-controllers
 
 */

private struct TopSitesLegacyView: UIViewControllerRepresentable {
    @EnvironmentObject var model: TopSitesModel
    @Environment(\.coordinatorsInterface) var coordinatorsInterface
    
    class Coordinator {}
    
    typealias UIViewControllerType = UIViewController
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        // TODO: pass whole app dependencies reference instead of specific one because it is nil at the time of execution
        let vc: AnyViewController & TopSitesInterface = ViewsEnvironment
            .shared
            .vcFactory
            .topSitesViewController(coordinatorsInterface)
        vc.reload(with: DefaultTabProvider.shared.topSites)
        return vc.viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
}
