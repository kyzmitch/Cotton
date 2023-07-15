//
//  SearchBarBaseViewController.swift
//  catowser
//
//  Created by admin on 19/02/2018.
//  Copyright © 2018 andreiermoshin. All rights reserved.
//

import UIKit
import CoreBrowser
import FeaturesFlagsKit

protocol SearchBarControllerInterface: AnyObject {
    /* non optional */ func handleAction(_ action: SearchBarAction)
}

final class SearchBarBaseViewController: BaseViewController {
    /// main search bar view
    private let searchBarView: SearchBarLegacyView
    
    init(_ searchBarDelegate: UISearchBarDelegate?) {
        let customFrame: CGRect
        if case .uiKit = FeatureManager.shared.appUIFrameworkValue() {
            customFrame = .zero
        } else {
            customFrame = .init(x: 0, y: 0, width: 0, height: .toolbarViewHeight)
        }
        searchBarView = .init(frame: customFrame)
        searchBarView.delegate = searchBarDelegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        TabsListManager.shared.detach(self)
    }

    override func loadView() {
        view = searchBarView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        TabsListManager.shared.attach(self)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        searchBarView.handleTraitCollectionChange()
    }
}

extension SearchBarBaseViewController: TabsObserver {
    func tabDidReplace(_ tab: Tab, at index: Int) {
        // this also can be called on non active tab
        // but at the same time it really doesn't make sense
        // to replace site on tab which is not active
        // So, assume that `tab` parameter is currently selected
        // and will replace content which is currently displayed by search bar
        handleAction(.updateView(tab.title, tab.searchBarContent))
    }

    func tabDidSelect(index: Int, content: Tab.ContentType, identifier: UUID) {
        switch content {
        case .site(let site):
            handleAction(.updateView(site.title, site.searchBarContent))
        default:
            handleAction(.clearView)
        }
    }
}

extension SearchBarBaseViewController: SearchBarControllerInterface {
    func handleAction(_ action: SearchBarAction) {
        searchBarView.handleAction(action)
    }
}
