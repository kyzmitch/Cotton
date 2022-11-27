//
//  SearchSuggestionsCoordinator.swift
//  catowser
//
//  Created by Andrei Ermoshin on 11/14/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import UIKit
import ReactiveSwift

protocol SearchSuggestionsControllerInterface: AnyObject {
    func prepareSearch(for searchText: String)
}

final class SearchSuggestionsCoordinator: Coordinator {
    let vcFactory: any ViewControllerFactory
    var startedCoordinator: Coordinator?
    weak var parent: CoordinatorOwner?
    var startedVC: AnyViewController?
    weak var presenterVC: AnyViewController?
    
    private weak var delegate: SearchSuggestionsListDelegate?
    private var _keyboardHeight: CGFloat?
    private var keyboardHeight: CGFloat? {
        get {
            return _keyboardHeight
        }
        set (newValue) {
            _keyboardHeight = newValue
        }
    }
    private let toolbarHeight: CGFloat
    private let topAnchor: NSLayoutYAxisAnchor
    private let toolbarTopAnchor: NSLayoutYAxisAnchor
    private var disposables = [Disposable?]()
    
    init(_ vcFactory: any ViewControllerFactory,
         _ presenter: AnyViewController,
         _ delegate: SearchSuggestionsListDelegate,
         _ topAnchor: NSLayoutYAxisAnchor,
         _ toolbarTopAnchor: NSLayoutYAxisAnchor,
         _ toolbarHeight: CGFloat) {
        self.vcFactory = vcFactory
        self.presenterVC = presenter
        self.delegate = delegate
        self.topAnchor = topAnchor
        self.toolbarTopAnchor = toolbarTopAnchor
        self.toolbarHeight = toolbarHeight
    }
    
    func start() {
        disposables.forEach { $0?.dispose() }
        
        let disposeB = NotificationCenter.default.reactive
            .notifications(forName: UIResponder.keyboardWillHideNotification)
            .observe(on: UIScheduler())
            .observeValues { [weak self] (notification) in
                self?.keyboardWillHideClosure()(notification)
        }

        let disposeA = NotificationCenter.default.reactive
            .notifications(forName: UIResponder.keyboardDidChangeFrameNotification)
            .observe(on: UIScheduler())
            .observeValues { [weak self] notification in
                self?.keyboardWillChangeFrameClosure()(notification)
        }

        disposables.append(disposeB)
        disposables.append(disposeA)
        
        guard let controllerView = presenterVC?.controllerView else {
            return
        }
        guard let delegate = delegate else {
            return
        }
        
        let vc = vcFactory.searchSuggestionsViewController(delegate)
        startedVC = vc
        presenterVC?.viewController.add(asChildViewController: vc.viewController, to: controllerView)

        vc.controllerView.topAnchor.constraint(equalTo: topAnchor,
                                               constant: 0).isActive = true
        vc.controllerView.leadingAnchor.constraint(equalTo: controllerView.leadingAnchor,
                                                   constant: 0).isActive = true
        vc.controllerView.trailingAnchor.constraint(equalTo: controllerView.trailingAnchor,
                                                    constant: 0).isActive = true

        if let bottomShift = keyboardHeight {
            // fix wrong height of keyboard on Simulator when keyboard partly visible
            let correctedShift = bottomShift < toolbarHeight ? toolbarHeight : bottomShift
            vc.controllerView.bottomAnchor.constraint(equalTo: controllerView.bottomAnchor,
                                                      constant: -correctedShift).isActive = true
        } else {
            if isPad {
                vc.controllerView.bottomAnchor.constraint(equalTo: toolbarTopAnchor,
                                                          constant: 0).isActive = true
            } else {
                vc.controllerView.bottomAnchor.constraint(equalTo: controllerView.bottomAnchor,
                                                          constant: 0).isActive = true
            }
        }
    }
}

enum SearchSuggestionsRoute: Route {
    case startSearch(String)
}

extension SearchSuggestionsCoordinator: Navigating {
    typealias R = SearchSuggestionsRoute
    
    func showNext(_ route: SearchSuggestionsRoute) {
        switch route {
        case .startSearch(let searchText):
            guard let interface = startedVC?.viewController as? SearchSuggestionsControllerInterface else {
                return
            }
            interface.prepareSearch(for: searchText)
        }
    }
    
    func stop() {
        disposables.forEach { $0?.dispose() }

        startedVC?.viewController.willMove(toParent: nil)
        startedVC?.viewController.removeFromParent()
        // remove view and constraints
        startedVC?.viewController.view.removeFromSuperview()
    }
}

private extension SearchSuggestionsCoordinator {
    func keyboardWillChangeFrameClosure() -> (Notification) -> Void {
        func handling(_ notification: Notification) {
            guard let info = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] else { return }
            guard let value = info as? NSValue else { return }
            let rect = value.cgRectValue

            // need to reduce search suggestions list height
            _keyboardHeight = rect.size.height
        }

        return handling
    }

    func keyboardWillHideClosure() -> (Notification) -> Void {
        func handling(_ notification: Notification) {
            _keyboardHeight = nil
        }

        return handling
    }
}

extension SearchSuggestionsCoordinator: CoordinatorOwner {
    func didFinish() {
        startedCoordinator = nil
    }
}
