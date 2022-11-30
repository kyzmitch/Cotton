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
    /// Layout handler for supplementary views.
    private var layoutCoordinator: AppLayoutCoordinator {
        // swiftlint:disable:next force_unwrapping
        return coordinator!.layoutCoordinator!
    }
    
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
    
    /// The view needed to hold tab content like WebView or favorites table view.
    let containerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .white
        return v
    }()
    
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

    private let isPad: Bool = UIDevice.current.userInterfaceIdiom == .pad
    
    // MARK: - Overrided functions from base type
    
    override func loadView() {
        // Your custom implementation of this method should not call super.
        view = UIView()
        
        // In that method, create your view hierarchy programmatically and assign
        // the root view of that hierarchy to the view controller’s view property.
        
        coordinator?.insertNext(.tabs)
        coordinator?.insertNext(.searchBar)
        coordinator?.insertNext(.loadingProgress)
        view.addSubview(containerView)

        if isPad {
            // no need to add files greed as a child
            // will try to show as popover
            view.addSubview(underLinkTagsView)
            coordinator?.insertNext(.linkTags)
        } else {
            coordinator?.insertNext(.filesGreed)
            // should be added before iPhone toolbar
            coordinator?.insertNext(.linkTags)
            coordinator?.insertNext(.toolbar)
            // Need to not add it if it is not iPhone without home button
            view.addSubview(underToolbarView)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        
        coordinator?.insertNext(.layoutTabs)
        coordinator?.insertNext(.layoutSearchBar)
        if isPad {
            setupTabletConstraints()
        } else {
            guard let toolbarView = coordinator?.toolbarView else {
                assertionFailure("Toolbar coordinator wasn't started")
                return
            }
            setupPhoneConstraints(toolbarView)
        }

        if !isPad {
            let filesView: UIView = layoutCoordinator.filesGreedController.controllerView
            filesView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            filesView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            // temporarily use 0 height because actual height of free space is
            // unknown at the moment
            let greedHeight: CGFloat = 0
            layoutCoordinator.hiddenFilesGreedConstraint = filesView.bottomAnchor.constraint(equalTo: tagsView.topAnchor,
                                                                                       constant: greedHeight)
            layoutCoordinator.showedFilesGreedConstraint = filesView.bottomAnchor.constraint(equalTo: tagsView.topAnchor)
            layoutCoordinator.filesGreedHeightConstraint = filesView.heightAnchor.constraint(equalToConstant: greedHeight)
            layoutCoordinator.hiddenFilesGreedConstraint?.isActive = true
            layoutCoordinator.filesGreedHeightConstraint?.isActive = true
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
            let freeHeight: CGFloat
            let allHeight = containerView.bounds.height
            freeHeight = allHeight - .linkTagsHeight
            
            layoutCoordinator.filesGreedHeightConstraint?.constant = freeHeight
            layoutCoordinator.hiddenFilesGreedConstraint?.constant = freeHeight
            let filesView: UIView = layoutCoordinator.filesGreedController.controllerView
            filesView.setNeedsLayout()
            filesView.layoutIfNeeded()
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
        // Need to have not simple view controller view but container view
        // to have ability to insert to it and show view controller with
        // bookmarks in case if search bar has no any address entered or
        // webpage controller with web view if some address entered in search bar
        containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        underLinkTagsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        underLinkTagsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        let dummyViewHeight: CGFloat = .safeAreaBottomMargin
        let linksHConstraint = underLinkTagsView.heightAnchor.constraint(equalToConstant: dummyViewHeight)
        layoutCoordinator.underLinksViewHeightConstraint = linksHConstraint
        layoutCoordinator.underLinksViewHeightConstraint?.isActive = true

        let bottomMargin: CGFloat = dummyViewHeight + .linkTagsHeight
        layoutCoordinator.hiddenTagsConstraint = underLinkTagsView.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                                                                     constant: bottomMargin)
        layoutCoordinator.showedTagsConstraint = underLinkTagsView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        
        coordinator?.insertNext(.startLayoutLinkTags(underLinkTagsView.topAnchor))
    }
    
    func setupPhoneConstraints(_ toolbarView: UIView) {
        toolbarView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.bottomAnchor.constraint(equalTo: toolbarView.topAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        toolbarView.topAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        toolbarView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        toolbarView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        toolbarView.heightAnchor.constraint(equalToConstant: .tabBarHeight).isActive = true
        if #available(iOS 11, *) {
            toolbarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            toolbarView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
        
        underToolbarView.topAnchor.constraint(equalTo: toolbarView.bottomAnchor).isActive = true
        underToolbarView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        underToolbarView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        underToolbarView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        coordinator?.insertNext(.startLayoutLinkTags(toolbarView.topAnchor))
    }
}
