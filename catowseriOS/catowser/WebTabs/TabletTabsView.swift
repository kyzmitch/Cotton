//
//  TabletTabsView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 1/13/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import SwiftUI

struct TabletTabsView: View {
    private let mode: SwiftUIMode
    
    init(_ mode: SwiftUIMode) {
        self.mode = mode
    }
    
    var body: some View {
        TabletTabsLegacyView()
            .frame(height: .tabHeight)
    }
}

private struct TabletTabsLegacyView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController
    
    private var vcFactory: ViewControllerFactory {
        ViewsEnvironment.shared.vcFactory
    }
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        let vc = vcFactory.tabsViewController()
        // swiftlint:disable:next force_unwrapping
        return vc!.viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}

#if DEBUG
struct TabletTabsView_Previews: PreviewProvider {
    static var previews: some View {
        TabletTabsView(.full)
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch) (3rd generation)"))
    }
}
#endif
