//
//  SearchBarV2View.swift
//  catowser
//
//  Created by Andrey Ermoshin on 10.12.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import SwiftUI

/// A search bar view
struct SearchBarView: View {
    private var model: SearchBarViewModel
    @Binding private var stateBinding: SearchBarState
    private let mode: SwiftUIMode
    
    init(_ model: SearchBarViewModel,
         _ stateBinding: Binding<SearchBarState>,
         _ mode: SwiftUIMode) {
        self.model = model
        _stateBinding = stateBinding
        self.mode = mode
    }
    
    var body: some View {
        switch mode {
        case .compatible:
            PhoneSearchBarLegacyView(model, $stateBinding)
                .frame(height: CGFloat.searchViewHeight)
        case .full:
            SearchBarViewV2(model, $stateBinding)
        }
    }
}

private struct PhoneSearchBarLegacyView: UIViewControllerRepresentable {
    private var model: SearchBarViewModel
    @Binding private var stateBinding: SearchBarState
    
    init(_ model: SearchBarViewModel,
         _ stateBinding: Binding<SearchBarState>) {
        self.model = model
        _stateBinding = stateBinding
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
        interface.changeState(to: stateBinding)
    }
}

#if DEBUG
struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        let model = SearchBarViewModel()
        let state: Binding<SearchBarState> = .init {
            // .viewMode("cotton", "cotton", true)
            .startSearch
        } set: { _ in
            //
        }
        // View is jumping when you tap on it
        SearchBarView(model, state, .compatible)
    }
}
#endif