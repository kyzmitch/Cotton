//
//  SearchBarBaseViewController.swift
//  catowser
//
//  Created by admin on 19/02/2018.
//  Copyright © 2018 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import UIKit
import CoreBrowser
import FeatureFlagsKit
import FeatureFlags
import CottonTabs
import CottonViewModels
import ViewsBase
import CottonDesignKit

@MainActor protocol SearchBarControllerInterface: AnyObject {
    /* non optional */ func handleAction(_ action: SearchBarAction)
}

/// Search bar base view controller
public final class SearchBarBaseViewController: BaseViewController {
    /// main search bar view
    private let searchBarView: SearchBarLegacyView<SearchBarViewModel>
    private let featureManager: FeatureManager.StateHolder
    private let tabsDataSubject: TabsDataSubject
    private let tabsSubjectFactory: () async -> TabsSubject

    /// Init
    public init(
        _ searchBarDelegate: UISearchBarDelegate?,
        _ uiFramework: UIFrameworkType,
        _ featureManager: FeatureManager.StateHolder,
        _ tabsDataSubject: TabsDataSubject,
        tabsSubjectFactory: @escaping () async -> TabsSubject,
        _ viewModel: SearchBarViewModel
    ) {
        let customFrame: CGRect
        if case .uiKit = uiFramework {
            customFrame = .zero
        } else {
            customFrame = .init(x: 0, y: 0, width: 0, height: .toolbarViewHeight)
        }
        searchBarView = .init(
            frame: customFrame,
            uiFramework: uiFramework,
            viewModel: viewModel
        )
        searchBarView.delegate = searchBarDelegate
        self.featureManager = featureManager
        self.tabsDataSubject = tabsDataSubject
        self.tabsSubjectFactory = tabsSubjectFactory
        super.init(nibName: nil, bundle: nil)
        
        Task {
            let observingType = await featureManager.observingApiTypeValue()
            if #available(iOS 17.0, *), observingType.isSystemObservation {
                startTabsObservation()
            } else {
                await tabsSubjectFactory().attach(self, notify: false)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func loadView() {
        view = searchBarView
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        searchBarView.handleTraitCollectionChange()
    }
    
    @available(iOS 17.0, *)
    @MainActor
    private func startTabsObservation() {
        withObservationTracking {
            _ = tabsDataSubject.selectedTabId
        } onChange: {
            Task { [weak self] in
                await self?.handleSelectedTabChange()
            }
        }
        withObservationTracking {
            _ = tabsDataSubject.replacedTabIndex
        } onChange: {
            Task { [weak self] in
                await self?.observeReplacedTab()
            }
        }
    }
    
    @available(iOS 17.0, *)
    @MainActor
    private func handleSelectedTabChange() async {
        let tabId = tabsDataSubject.selectedTabId
        guard let index = tabsDataSubject.tabs
            .firstIndex(where: { $0.id == tabId }) else {
            return
        }
        await tabDidSelect(index, tabsDataSubject.tabs[index].contentType, tabId)
    }
    
    @available(iOS 17.0, *)
    @MainActor
    private func observeReplacedTab() async {
        guard let index = tabsDataSubject.replacedTabIndex else {
            return
        }
        await tabDidReplace(tabsDataSubject.tabs[index], at: index)
    }
}

// MARK: - TabsObserver

extension SearchBarBaseViewController: TabsObserver {
    /// Notifies about tab content type changes or `site` changes
    ///
    /// - parameters:
    ///     - tab: new tab for replacement
    ///     - index: original tab's index whichneeds to be replaced
    public func tabDidReplace(_ tab: CoreBrowser.Tab, at index: Int) async {
        // this also can be called on non active tab
        // but at the same time it really doesn't make sense
        // to replace site on tab which is not active
        // So, assume that `tab` parameter is currently selected
        // and will replace content which is currently displayed by search bar
        handleAction(.updateView(tab.title, tab.searchBarContent))
    }

    /// Tells observer that index has changed.
    ///
    /// - parameters:
    ///     - index: new selected index.
    ///     - content: CoreBrowser.Tab content, e.g. can be site. Need to pass it to allow browser to change content in web view.
    ///     - identifier: needed to quickly determine visual state (selected view or not)
    public func tabDidSelect(
        _ index: Int,
        _ content: CoreBrowser.Tab.ContentType,
        _ identifier: UUID
    ) async {
        // Cancel search mode just in case if it was active
        handleAction(.cancelSearch)
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
