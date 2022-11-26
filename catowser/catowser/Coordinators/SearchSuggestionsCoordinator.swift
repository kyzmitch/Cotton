//
//  SearchSuggestionsCoordinator.swift
//  catowser
//
//  Created by Andrei Ermoshin on 11/14/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import UIKit
import ReactiveSwift

final class SearchSuggestionsCoordinator: Coordinator {
    let vcFactory: any ViewControllerFactory
    var startedCoordinator: Coordinator?
    weak var parent: CoordinatorOwner?
    var startedVC: AnyViewController?
    weak var presenterVC: AnyViewController?
    
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
         _ topAnchor: NSLayoutYAxisAnchor,
         _ toolbarTopAnchor: NSLayoutYAxisAnchor,
         _ toolbarHeight: CGFloat) {
        self.vcFactory = vcFactory
        self.presenterVC = presenter
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
        
        let vc = vcFactory.searchSuggestionsViewController(self)
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
        
        searchSuggestionsVC?.prepareSearch(for: searchText)
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

extension SearchSuggestionsCoordinator: SearchSuggestionsListDelegate {
    func didSelect(_ content: SuggestionType) {
        hideSearchController()

        switch content {
        case .looksLikeURL(let likeURL):
            guard let url = URL(string: likeURL) else {
                assertionFailure("Failed construct site URL using edited URL")
                return
            }
            presenter.openDomain(with: url)
        case .knownDomain(let domain):
            guard let url = URL(string: "https://\(domain)") else {
                assertionFailure("Failed construct site URL using domain name")
                return
            }
            presenter.openDomain(with: url)
        case .suggestion(let suggestion):
            guard let url = searchSuggestClient.searchURLForQuery(suggestion) else {
                assertionFailure("Failed construct search engine url from suggestion string")
                return
            }
            presenter.openSearchSuggestion(url: url, suggestion: suggestion)
        }
    }
}

extension SearchSuggestionsCoordinator: CoordinatorOwner {
    func didFinish() {
        startedCoordinator = nil
    }
}

enum SearchSuggestionsRoute: Route {}

extension SearchSuggestionsCoordinator: Navigating {
    typealias R = SearchSuggestionsRoute
    
    func showNext(_ route: SearchSuggestionsRoute) {
        
    }
    
    func stop() {
        disposables.forEach { $0?.dispose() }
        guard let searchSuggestionsController = searchSuggestionsVC else { return }

        searchSuggestionsController.willMove(toParent: nil)
        searchSuggestionsController.removeFromParent()
        // remove view and constraints
        searchSuggestionsController.view.removeFromSuperview()
    }
}
