//
//  PhoneSearchBarLegacyView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 4/21/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import SwiftUI

struct PhoneSearchBarLegacyView: UIViewControllerRepresentable {
    private var model: SearchBarViewModel
    @Binding private var state: SearchBarState
    
    init(_ model: SearchBarViewModel,
         _ state: Binding<SearchBarState>) {
        self.model = model
        _state = state
    }
    
    typealias UIViewControllerType = UIViewController
    
    private var vcFactory: ViewControllerFactory {
        ViewsEnvironment.shared.vcFactory
    }
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        let vc = vcFactory.deviceSpecificSearchBarViewController(model)
        // swiftlint:disable:next force_unwrapping
        return vc!.viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        guard let interface = uiViewController as? SearchBarControllerInterface else {
            return
        }
        interface.changeState(to: state)
    }
}
