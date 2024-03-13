//
//  TabsPreviewsLegacyView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 4/21/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import SwiftUI

/// Temporarily view for tabs previews, but dismiss is not implemented.
/// Probably should be handled in MainToolbarCoordinator didTabSelect
/// or PhoneTabsCoordinator showSelected
struct TabsPreviewsLegacyView: UIViewControllerRepresentable {

    init() {}
    
    typealias UIViewControllerType = UIViewController
    
    private var vcFactory: ViewControllerFactory {
        ViewsEnvironment.shared.vcFactory
    }
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        let interface = context.environment.browserContentCoordinators
        guard let coordinator = interface?.toolbarCoordinator?.startedCoordinator as? PhoneTabsCoordinator else {
            assertionFailure("Phone tabs coordinator should be started for SwiftUI compatible mode")
            return UIViewController()
        }
        let vc = coordinator.startedVC
        // swiftlint:disable:next force_unwrapping
        return vc!.viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
