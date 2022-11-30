//
//  WebBrowserToolbarController.swift
//  catowser
//
//  Created by admin on 19/02/2018.
//  Copyright © 2018 andreiermoshin. All rights reserved.
//
// This class and UI is only needed for iPhone/iPod touch
// and it is needed to provide interface buttons
// in the bottom of the screen for navigation on web site:
// back, forward, refresh page buttons and button to
// open separate screen with tabs with previews for
// currently opened websites. And last button to open
// settings for the application.

import UIKit
import CoreBrowser

// TODO: fix protocol name to Download
protocol DonwloadPanelDelegate: AnyObject {
    func didPressDownloads(to hide: Bool)
    func didPressTabletLayoutDownloads(from sourceView: UIView, and sourceRect: CGRect)
}

protocol GlobalMenuDelegate: AnyObject {
    func didPressSettings(from sourceView: UIView, and sourceRect: CGRect)
}

final class WebBrowserToolbarController<C: Navigating>: BaseViewController where C.R == ToolbarRoute {
    
    private weak var coordinator: C?

    init(_ coordinator: C,
         _ downloadDelegate: DonwloadPanelDelegate?,
         _ globalSettingsDelegate: GlobalMenuDelegate?) {
        self.coordinator = coordinator
        downloadPanelDelegate = downloadDelegate
        self.globalSettingsDelegate = globalSettingsDelegate
        downloadsViewHidden = true
        enableDownloadsButton = false
        super.init(nibName: nil, bundle: nil)
        TabsListManager.shared.attach(counterView)
        TabsListManager.shared.attach(self)
    }
    
    /// Site navigation delegate
    private weak var siteNavigationDelegate: SiteNavigationDelegate? {
        didSet {
            guard siteNavigationDelegate != nil else {
                backButton.isEnabled = false
                forwardButton.isEnabled = false
                reloadButton.isEnabled = false
                downloadsViewHidden = true
                enableDownloadsButton = false
                return
            }

            reloadNavigationElements(true)
        }
    }
    
    private weak var downloadPanelDelegate: DonwloadPanelDelegate?
    private weak var globalSettingsDelegate: GlobalMenuDelegate?

    fileprivate var downloadsViewHidden: Bool = true {
        didSet {
            animateDownloadsArrow(down: !downloadsViewHidden)
        }
    }
    
    fileprivate var enableDownloadsButton: Bool {
        didSet {
            downloadLinksButton.isEnabled = enableDownloadsButton
            downloadsView.alpha = enableDownloadsButton ? 1.0 : 0.3
        }
    }
    
    private lazy var standardToolbarButtons: [UIBarButtonItem] = {
        var barItems = [UIBarButtonItem]()
        barItems.append(backButton)
        let space1 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        barItems.append(space1)
        barItems.append(forwardButton)
        let space2 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        barItems.append(space2)
        barItems.append(reloadButton)
        let space3 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        barItems.append(space3)
        barItems.append(openedTabsButton)
        return barItems
    }()

    private lazy var toolbarView: CottonToolbarView = {
        let toolbar = CottonToolbarView(frame: .zero)
        ThemeProvider.shared.setup(toolbar)
        toolbar.counterView = counterView
        toolbar.downloadsView = downloadsView
        toolbar.setItems(standardToolbarButtons, animated: false)
        return toolbar
    }()
    
    private lazy var backButton: UIBarButtonItem = {
        let img = UIImage(named: "nav-back")
        let back = #selector(WebBrowserToolbarController.handleBackPressed)
        let btn = UIBarButtonItem(image: img, style: .plain, target: self, action: back)
        return btn
    }()
    
    private lazy var forwardButton: UIBarButtonItem = {
        let img = UIImage(named: "nav-forward")
        let forward = #selector(WebBrowserToolbarController.handleForwardPressed)
        let btn = UIBarButtonItem(image: img, style: .plain, target: self, action: forward)
        return btn
    }()
    
    private lazy var reloadButton: UIBarButtonItem = {
        let img = UIImage(named: "nav-refresh")
        let reload = #selector(WebBrowserToolbarController.handleReloadPressed)
        let btn = UIBarButtonItem(image: img, style: .plain, target: self, action: reload)
        return btn
    }()
    
    private lazy var actionsButton: UIBarButtonItem = {
        let btn: UIBarButtonItem
        let actions = #selector(WebBrowserToolbarController.handleActionsPressed)
        if #available(iOS 13.0, *) {
            if let systemImage = UIImage.arropUp {
                btn = .init(image: systemImage, style: .plain, target: self, action: actions)
            } else {
                btn = .init(barButtonSystemItem: .action, target: self, action: actions)
            }
        } else {
            btn = .init(barButtonSystemItem: .action, target: self, action: actions)
        }
        return btn
    }()

    private let counterView: CounterView = CounterView(frame: .zero)
    
    private lazy var openedTabsButton: UIBarButtonItem = {
        counterView.digit = TabsListManager.shared.tabsCount
        // Can't use simple bar button with text because it positioned incorrectly
        let btn = UIBarButtonItem(customView: counterView)
        return btn
    }()

    private lazy var downloadsView: UIImageView = {
        let img = UIImage(named: "nav-downloads")
        let imgView = UIImageView(image: img)
        return imgView
    }()
    
    private lazy var downloadLinksButton: UIBarButtonItem = {
        let downloads = #selector(WebBrowserToolbarController.handleDownloadsPressed)
        let btn = UIBarButtonItem(customView: downloadsView)
        btn.target = self
        btn.action = downloads
        return btn
    }()

    deinit {
        TabsListManager.shared.detach(self)
        TabsListManager.shared.detach(counterView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = toolbarView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // disabled after `init` because no web view is present
        backButton.isEnabled = false
        forwardButton.isEnabled = false
        reloadButton.isEnabled = false
        downloadLinksButton.isEnabled = false
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Workaround for UIBarButtonItem with a custom UIView
        // for strange reason it can't recognize gesture recognizers or
        // even target-action for this specific view
        for touch in touches {
            if touch.view == counterView {
                handleShowOpenedTabsPressed()
                break
            } else if touch.view == downloadsView && enableDownloadsButton {
                handleDownloadsPressed()
                break
            }
        }
    }
    
    // MARK: - private functions
    
    private func animateDownloadsArrow(down: Bool) {
        let rotate = UIViewPropertyAnimator(duration: 0.33, curve: .easeIn)
        rotate.addAnimations {
            let angle = down ? CGFloat.pi : 0
            self.downloadsView.transform = CGAffineTransform(rotationAngle: angle)
        }
        rotate.startAnimation()
    }

    @objc private func handleBackPressed() {
        siteNavigationDelegate?.goBack()
        refreshNavigation()
    }

    @objc private func handleForwardPressed() {
        siteNavigationDelegate?.goForward()
        refreshNavigation()
    }

    @objc private func handleReloadPressed() {
        siteNavigationDelegate?.reload()
    }
    
    @objc private func handleActionsPressed() {
        if let siteDelegate = siteNavigationDelegate {
            // TODO: handle browser settings with Site info
        } else {
            globalSettingsDelegate?.didPressSettings(from: toolbarView, and: .zero)
        }
    }

    @objc private func handleShowOpenedTabsPressed() {
        coordinator?.showNext(.tabs)
    }

    @objc private func handleDownloadsPressed() {
        downloadsViewHidden.toggle() // should call didSet
        downloadPanelDelegate?.didPressDownloads(to: downloadsViewHidden)
    }
    
    private func refreshNavigation() {
        forwardButton.isEnabled = siteNavigationDelegate?.canGoForward ?? false
        backButton.isEnabled = siteNavigationDelegate?.canGoBack ?? false
    }
    
    private func updateToolbar(downloadsAvailable: Bool, actionsAvailable: Bool) {
        var barItems = standardToolbarButtons
        if actionsAvailable {
            let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            barItems.append(space)
            barItems.append(actionsButton)
        }
        if downloadsAvailable {
            let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            barItems.append(space)
            barItems.append(downloadLinksButton)
        }
        toolbarView.setItems(barItems, animated: true)
    }
}

extension WebBrowserToolbarController: FullSiteNavigationComponent {
    func changeBackButton(to canGoBack: Bool) {
        backButton.isEnabled = canGoBack
    }
    
    func changeForwardButton(to canGoForward: Bool) {
        forwardButton.isEnabled = canGoForward
    }
    
    func reloadNavigationElements(_ withSite: Bool, downloadsAvailable: Bool = false) {
        // this will be useful when user will change current web view
        backButton.isEnabled = siteNavigationDelegate?.canGoBack ?? false
        forwardButton.isEnabled = siteNavigationDelegate?.canGoForward ?? false
        reloadButton.isEnabled = withSite
        updateToolbar(downloadsAvailable: downloadsAvailable, actionsAvailable: true)
        downloadsViewHidden = !downloadsAvailable
        enableDownloadsButton = downloadsAvailable
    }

    var siteNavigator: SiteNavigationDelegate? {
        get {
            return siteNavigationDelegate
        }
        set (newValue) {
            siteNavigationDelegate = newValue
        }
    }
}

extension CounterView: TabsObserver {
    func update(with tabsCount: Int) {
        self.digit = tabsCount
    }
}

extension WebBrowserToolbarController: TabsObserver {
    func tabDidSelect(index: Int, content: Tab.ContentType, identifier: UUID) {
        switch content {
        case .site:
            updateToolbar(downloadsAvailable: false, actionsAvailable: true)
        default:
            // allow to show actions even for top sites view
            // to be able for user to get to global settings
            updateToolbar(downloadsAvailable: false, actionsAvailable: true)
        }
    }
}
