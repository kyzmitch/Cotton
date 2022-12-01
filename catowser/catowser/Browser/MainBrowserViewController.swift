//
//  MainBrowserViewController.swift
//  catowser
//
//  Created by Andrey Ermoshin on 27/09/2017.
//  Copyright © 2017 andreiermoshin. All rights reserved.
//

import UIKit
import ReactiveSwift
import CoreBrowser
import FeaturesFlagsKit
import JSPlugins
import CoreHttpKit
import CoreCatowser

final class MainBrowserViewController<C: Navigating & SubviewNavigation>: BaseViewController, BrowserContentViewHolder
    where C.R == MainScreenRoute, C.SP == MainScreenSubview {
    /// Define a specific type of coordinator, because not any coordinator
    /// can be used for this specific view controller
    /// and also the routes are specific to this screen as well.
    /// Storing it by weak reference, it is stored strongly in the coordinator owner
    private weak var coordinator: C?
    
    // MARK: - initializers
    
    init(_ coordinator: C) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        // was in `viewWillDisappear` before
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - BrowserContentViewHolder

    
    var underToolbarViewBounds: CGRect {
        underToolbarView.bounds
    }
    
    // MARK: - Other properties

    /// View to make color under toolbar is the same on iPhone x without home button
    private lazy var underToolbarView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        ThemeProvider.shared.setupUnderToolbar(v)
        return v
    }()

    private lazy var underLinkTagsView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        ThemeProvider.shared.setupUnderLinkTags(v)
        return v
    }()
    
    // MARK: - Overrided functions from base type
    
    override func loadView() {
        // Your custom implementation of this method should not call super.
        view = UIView()
        
        // In that method, create your view hierarchy programmatically and assign
        // the root view of that hierarchy to the view controller’s view property.
        
        if isPad {
            coordinator?.insertNext(.tabs)
        }
        coordinator?.insertNext(.searchBar)
        coordinator?.insertNext(.loadingProgress)
        coordinator?.insertNext(.webContentContainer)

        if isPad {
            // no need to add files greed as a child
            // will try to show as popover
            coordinator?.insertNext(.linkTags)
            view.addSubview(underLinkTagsView)
        } else {
            // should be added before iPhone toolbar
            coordinator?.insertNext(.linkTags)
            // files grid MUST be added after link tags
            // but layout goes before link tags
            coordinator?.insertNext(.filesGrid)
            coordinator?.insertNext(.toolbar)
            // Need to not add it if it is not iPhone without home button
            view.addSubview(underToolbarView)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        
        if isPad {
            coordinator?.insertNext(.tabsViewDidLoad)
        }
        coordinator?.insertNext(.searchBarViewDidLoad)
        coordinator?.insertNext(.loadingProgressViewDidLoad)
        if isPad {
            setupTabletConstraints()
        } else {
            setupPhoneConstraints()
        }

        if !isPad {
            coordinator?.insertNext(.filesGridViewDidLoad)
        }
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()

        // only here we can get correct value for
        // safe area inset
        if isPad {
            layoutCoordinator.underLinksViewHeightConstraint?.constant = view.safeAreaInsets.bottom
            underLinkTagsView.setNeedsLayout()
            underLinkTagsView.layoutIfNeeded()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !isPad {
            containerView.bounds.height
            coordinator?.insertNext(.filesGridViewDidLayoutSubviews)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return ThemeProvider.shared.theme.statusBarStyle
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

private extension MainBrowserViewController {
    func setupTabletConstraints() {
        coordinator?.insertNext(.webContentContainerViewDidLoad)

        underLinkTagsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        underLinkTagsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        let dummyViewHeight: CGFloat = .safeAreaBottomMargin
        let linksHConstraint = underLinkTagsView.heightAnchor.constraint(equalToConstant: dummyViewHeight)
        layoutCoordinator.underLinksViewHeightConstraint = linksHConstraint
        layoutCoordinator.underLinksViewHeightConstraint?.isActive = true

        coordinator?.insertNext(.linkTagsViewDidLoad(underLinkTagsView.topAnchor, underLinkTagsView.bottomAnchor))
    }
    
    func setupPhoneConstraints() {
        coordinator?.insertNext(.webContentContainerViewDidLoad)
        coordinator?.insertNext(.toolbarViewDidLoad)
        
        underToolbarView.topAnchor.constraint(equalTo: toolbarView.bottomAnchor).isActive = true
        underToolbarView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        underToolbarView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        underToolbarView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        coordinator?.insertNext(.linkTagsViewDidLoad(toolbarView.topAnchor, nil))
    }
}
