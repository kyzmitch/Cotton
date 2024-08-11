//
//  SearchBarBaseViewController.swift
//  catowser
//
//  Created by admin on 19/02/2018.
//  Copyright © 2018 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import UIKit
import CoreBrowser
import FeaturesFlagsKit

@MainActor protocol SearchBarControllerInterface: AnyObject {
    /* non optional */ func handleAction(_ action: SearchBarAction)
}

final class SearchBarBaseViewController: BaseViewController {
    /// main search bar view
    private let searchBarView: SearchBarLegacyView

    init(_ searchBarDelegate: UISearchBarDelegate?, _ uiFramework: UIFrameworkType) {
        let customFrame: CGRect
        if case .uiKit = uiFramework {
            customFrame = .zero
        } else {
            customFrame = .init(x: 0, y: 0, width: 0, height: .toolbarViewHeight)
        }
        searchBarView = .init(frame: customFrame, uiFramework: uiFramework)
        searchBarView.delegate = searchBarDelegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = searchBarView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Task {
            await TabsDataService.shared.attach(self)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        Task {
            await TabsDataService.shared.detach(self)
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        searchBarView.handleTraitCollectionChange()
    }
}

extension SearchBarBaseViewController: TabsObserver {
    func tabDidReplace(_ tab: CoreBrowser.Tab, at index: Int) async {
        // this also can be called on non active tab
        // but at the same time it really doesn't make sense
        // to replace site on tab which is not active
        // So, assume that `tab` parameter is currently selected
        // and will replace content which is currently displayed by search bar
        handleAction(.updateView(tab.title, tab.searchBarContent))
    }

    func tabDidSelect(_ index: Int, _ content: CoreBrowser.Tab.ContentType, _ identifier: UUID) async {
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
