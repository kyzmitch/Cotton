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
        disposables.forEach { $0?.dispose() }
    }
    
    // MARK: - BrowserContentViewHolder
    
    /// The view needed to hold tab content like WebView or favorites table view.
    let containerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .white
        return v
    }()
    
    // MARK: - Other properties
    
    /// Tabs list without previews. Needed only for tablets or landscape mode.
    private lazy var tabsViewController: TabsViewController = {
        let viewController = TabsViewController()
        return viewController
    }()

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

    var mKeyboardHeight: CGFloat?

    private var disposables = [Disposable?]()

    private let isPad: Bool = UIDevice.current.userInterfaceIdiom == .pad
    
    // MARK: - Overrided functions from base type
    
    override func loadView() {
        // Your custom implementation of this method should not call super.
        view = UIView()
        
        // In that method, create your view hierarchy programmatically and assign
        // the root view of that hierarchy to the view controller’s view property.
        
        if isPad {
            add(asChildViewController: tabsViewController, to: view)
        }

        add(asChildViewController: layoutCoordinator.searchBarController.viewController, to: view)
        coordinator?.insertNext(.loadingProgress)
        view.addSubview(containerView)

        if isPad {
            // no need to add files greed as a child
            // will try to show as popover

            view.addSubview(underLinkTagsView)
            add(asChildViewController: layoutCoordinator.linkTagsController.viewController, to: view)
        } else {
            add(asChildViewController: layoutCoordinator.filesGreedController.viewController, to: view)
            // should be added before iPhone toolbar
            add(asChildViewController: layoutCoordinator.linkTagsController.viewController, to: view)
            coordinator?.insertNext(.toolbar(view, layoutCoordinator))
            // Need to not add it if it is not iPhone without home button
            view.addSubview(underToolbarView)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        let tagsView = layoutCoordinator.linkTagsController.controllerView
        tagsView.translatesAutoresizingMaskIntoConstraints = false
        let searchView = layoutCoordinator.searchBarController.controllerView
        searchView.translatesAutoresizingMaskIntoConstraints = false
        
        if isPad {
            setupTabletConstraints(searchView, tagsView)
        } else {
            guard let toolbarView = coordinator?.toolbarView else {
                assertionFailure("Toolbar coordinator wasn't started")
                return
            }
            setupPhoneConstraints(searchView, tagsView, toolbarView)
        }
        
        layoutCoordinator.hiddenWebLoadConstraint = webLoadProgressView.heightAnchor.constraint(equalToConstant: 0)
        layoutCoordinator.showedWebLoadConstraint = webLoadProgressView.heightAnchor.constraint(equalToConstant: 6)
        layoutCoordinator.hiddenWebLoadConstraint?.isActive = true
        webLoadProgressView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webLoadProgressView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        layoutCoordinator.hiddenTagsConstraint?.isActive = true
        tagsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tagsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tagsView.heightAnchor.constraint(equalToConstant: .linkTagsHeight).isActive = true

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

        setupObservers()
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
    func setupTabletConstraints(_ searchView: UIView, _ tagsView: UIView) {
        let tabsView: UIView = tabsViewController.view
        tabsView.translatesAutoresizingMaskIntoConstraints = false
        // https://github.com/SnapKit/SnapKit/issues/448
        // https://developer.apple.com/documentation/uikit/uiviewcontroller/1621367-toplayoutguide
        // https://developer.apple.com/documentation/uikit/uiview/2891102-safearealayoutguide
        if #available(iOS 11, *) {
            tabsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            tabsView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        }
        tabsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tabsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tabsView.heightAnchor.constraint(equalToConstant: .tabHeight).isActive = true
        
        searchView.topAnchor.constraint(equalTo: tabsView.bottomAnchor).isActive = true
        searchView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        searchView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        searchView.heightAnchor.constraint(equalToConstant: .searchViewHeight).isActive = true
        
        let sbViewBottomAnchor = searchView.bottomAnchor
        webLoadProgressView.topAnchor.constraint(equalTo: sbViewBottomAnchor).isActive = true
        
        // Need to have not simple view controller view but container view
        // to have ability to insert to it and show view controller with
        // bookmarks in case if search bar has no any address entered or
        // webpage controller with web view if some address entered in search bar
        containerView.topAnchor.constraint(equalTo: webLoadProgressView.bottomAnchor).isActive = true
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
        let tagsBottom = tagsView.bottomAnchor
        tagsBottom.constraint(equalTo: underLinkTagsView.topAnchor).isActive = true
    }
    
    func setupPhoneConstraints(_ searchView: UIView, _ tagsView: UIView, _ toolbarView: UIView) {
        if #available(iOS 11, *) {
            searchView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            searchView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        }
        searchView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        searchView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        searchView.heightAnchor.constraint(equalToConstant: .searchViewHeight).isActive = true
        
        webLoadProgressView.topAnchor.constraint(equalTo: searchView.bottomAnchor).isActive = true
        
        toolbarView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.topAnchor.constraint(equalTo: webLoadProgressView.bottomAnchor).isActive = true
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
        
        layoutCoordinator.hiddenTagsConstraint = tagsView.bottomAnchor.constraint(equalTo: toolbarView.topAnchor,
                                                                            constant: .linkTagsHeight)
        layoutCoordinator.showedTagsConstraint = tagsView.bottomAnchor.constraint(equalTo: toolbarView.topAnchor)
    }
    
    func setupObservers() {
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

        // add coordinator as an observer to `TabsSubject` will happen in coordinator
    }
    
    func keyboardWillChangeFrameClosure() -> (Notification) -> Void {
        func handling(_ notification: Notification) {
            guard let info = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] else { return }
            guard let value = info as? NSValue else { return }
            let rect = value.cgRectValue

            // need to reduce search suggestions list height
            mKeyboardHeight = rect.size.height
        }

        return handling
    }

    func keyboardWillHideClosure() -> (Notification) -> Void {
        func handling(_ notification: Notification) {
            mKeyboardHeight = nil
        }

        return handling
    }

    func replaceTab(with url: URL, with suggestion: String? = nil) {
        let blockPopups = DefaultTabProvider.shared.blockPopups
        let isJSEnabled = FeatureManager.boolValue(of: .javaScriptEnabled)
        let settings = Site.Settings(isPrivate: false,
                                     blockPopups: blockPopups,
                                     isJSEnabled: isJSEnabled,
                                     canLoadPlugins: true)
        guard let site = Site.create(url: url,
                                     searchSuggestion: suggestion,
                                     settings: settings) else {
            assertionFailure("\(#function) failed to replace current tab - failed create site")
            return
        }
        // tab content replacing will happen in `didCommit`
        coordinator?.insertNext(.openTab(.site(site)))
    }
}

extension MainBrowserViewController: MainDelegate {
    var popoverSourceView: UIView {
        return containerView
    }

    var keyboardHeight: CGFloat? {
        get {
            return mKeyboardHeight
        }
        set (newValue) {
            mKeyboardHeight = newValue
        }
    }

    /// Dynamicly determined height because it can be different before layout finish it's work
    var toolbarHeight: CGFloat {
        // swiftlint:disable:next force_unwrapping
        let toolbarHeight = (coordinator?.toolbarView?.bounds.size.height)!
        return toolbarHeight + underToolbarView.bounds.size.height
    }

    var toolbarTopAnchor: NSLayoutYAxisAnchor {
        return (coordinator?.toolbarView?.topAnchor)!
    }

    func openSearchSuggestion(url: URL, suggestion: String) {
        replaceTab(with: url, with: suggestion)
    }

    func openDomain(with url: URL) {
        replaceTab(with: url)
    }
}
