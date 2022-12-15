//
//  SearchBarBaseViewController.swift
//  catowser
//
//  Created by admin on 19/02/2018.
//  Copyright © 2018 andreiermoshin. All rights reserved.
//

import UIKit
import CoreBrowser

protocol SearchBarControllerInterface: AnyObject {
    /* non optional */ func changeState(to state: SearchBarState)
}

final class SearchBarBaseViewController: BaseViewController {
    /// main search bar view
    private let searchBarView: SearchBarLegacyView
    
    init(_ searchBarDelegate: UISearchBarDelegate?) {
        searchBarView = .init(frame: .zero)
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
}

extension SearchBarBaseViewController: TabsObserver {
    func tabDidReplace(_ tab: Tab, at index: Int) {
        // this also can be called on non active tab
        // but at the same time it really doesn't make sense
        // to replace site on tab which is not active
        // So, assume that `tab` parameter is currently selected
        // and will replace content which is currently disprlayed by search bar

        let state: SearchBarState = .viewMode(tab.title, tab.searchBarContent, true)
        changeState(to: state)
    }

    func tabDidSelect(index: Int, content: Tab.ContentType, identifier: UUID) {
        let state: SearchBarState

        switch content {
        case .site(let site):
            state = .viewMode( site.title, site.searchBarContent, false)
        default:
            state = .blankSearch
        }

        // run without animation, because label with search query
        // slides when web view has already displayed
        changeState(to: state)
    }
}

extension SearchBarBaseViewController: SearchBarControllerInterface {
    func changeState(to state: SearchBarState) {
        searchBarView.state = state
    }
}
