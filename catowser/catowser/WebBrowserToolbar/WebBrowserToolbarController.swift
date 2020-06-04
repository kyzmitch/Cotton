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

protocol DonwloadPanelDelegate: class {
    func didPressDownloads(to hide: Bool)
}

protocol GlobalMenuDelegate: class {
    func didPressSettings(from sourceView: UIView, and sourceRect: CGRect)
}

final class WebBrowserToolbarController: UIViewController {

    /// Site navigation delegate
    private weak var siteNavigationDelegate: SiteNavigationDelegate? {
        didSet {
            guard siteNavigationDelegate != nil else {
                backButton.isEnabled = false
                forwardButton.isEnabled = false
                reloadButton.isEnabled = false
                downloadsArrowDown = true
                enableDownloadsButton = false
                return
            }

            reloadNavigationElements(true)
        }
    }
    
    weak var downloadPanelDelegate: DonwloadPanelDelegate?
    
    weak var globalSettingsDelegate: GlobalMenuDelegate?

    fileprivate var downloadsArrowDown: Bool = true {
        didSet {
            animateDownloadsArrow(down: !downloadsArrowDown)
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
        let btn = UIBarButtonItem(image: img, style: .plain, target: self, action: .back)
        return btn
    }()
    
    private lazy var forwardButton: UIBarButtonItem = {
        let img = UIImage(named: "nav-forward")
        let btn = UIBarButtonItem(image: img, style: .plain, target: self, action: .forward)
        return btn
    }()
    
    private lazy var reloadButton: UIBarButtonItem = {
        let img = UIImage(named: "nav-refresh")
        let btn = UIBarButtonItem(image: img, style: .plain, target: self, action: .reload)
        return btn
    }()
    
    private lazy var actionsButton: UIBarButtonItem = {
        let btn: UIBarButtonItem
        if #available(iOS 13.0, *) {
            if let systemImage = UIImage.arropUp {
                btn = .init(image: systemImage, style: .plain, target: self, action: .actions)
            } else {
                btn = .init(barButtonSystemItem: .action, target: self, action: .actions)
            }
        } else {
            btn = .init(barButtonSystemItem: .action, target: self, action: .actions)
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
        let btn = UIBarButtonItem(customView: downloadsView)
        btn.target = self
        btn.action = .downloads
        return btn
    }()

    private let router: ToolbarRouter

    init(router: ToolbarRouter,
         downloadDelegate: DonwloadPanelDelegate,
         globalSettingsDelegate: GlobalMenuDelegate) {
        self.router = router
        downloadPanelDelegate = downloadDelegate
        self.globalSettingsDelegate = globalSettingsDelegate
        downloadsArrowDown = true
        enableDownloadsButton = false
        super.init(nibName: nil, bundle: nil)
        TabsListManager.shared.attach(counterView)
        TabsListManager.shared.attach(self)
    }

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
}

extension WebBrowserToolbarController: SiteNavigationComponent {
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
        downloadsArrowDown = !downloadsAvailable
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

private extension WebBrowserToolbarController {
    func animateDownloadsArrow(down: Bool) {
        let rotate = UIViewPropertyAnimator(duration: 0.33, curve: .easeIn)
        rotate.addAnimations {
            let angle = down ? CGFloat.pi : 0
            self.downloadsView.transform = CGAffineTransform(rotationAngle: angle)
        }
        rotate.startAnimation()
    }

    @objc func handleBackPressed() {
        siteNavigationDelegate?.goBack()
        refreshNavigation()
    }

    @objc func handleForwardPressed() {
        siteNavigationDelegate?.goForward()
        refreshNavigation()
    }

    @objc func handleReloadPressed() {
        siteNavigationDelegate?.reload()
    }
    
    @objc func handleActionsPressed() {
        if let siteDelegate = siteNavigationDelegate {
            siteDelegate.openTabMenu(from: toolbarView, and: .zero)
        } else {
            globalSettingsDelegate?.didPressSettings(from: toolbarView, and: .zero)
        }
    }

    @objc func handleShowOpenedTabsPressed() {
        router.showTabs()
    }

    @objc func handleDownloadsPressed() {
        downloadsArrowDown = !downloadsArrowDown
        downloadPanelDelegate?.didPressDownloads(to: downloadsArrowDown)
    }
    
    func refreshNavigation() {
        forwardButton.isEnabled = siteNavigationDelegate?.canGoForward ?? false
        backButton.isEnabled = siteNavigationDelegate?.canGoBack ?? false
    }
    
    func updateToolbar(downloadsAvailable: Bool, actionsAvailable: Bool) {
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

fileprivate extension Selector {
    static let back = #selector(WebBrowserToolbarController.handleBackPressed)
    static let forward = #selector(WebBrowserToolbarController.handleForwardPressed)
    static let reload = #selector(WebBrowserToolbarController.handleReloadPressed)
    static let actions = #selector(WebBrowserToolbarController.handleActionsPressed)
    static let openTabs = #selector(WebBrowserToolbarController.handleShowOpenedTabsPressed)
    static let downloads = #selector(WebBrowserToolbarController.handleDownloadsPressed)
}

extension CounterView: TabsObserver {
    func update(with tabsCount: Int) {
        self.digit = tabsCount
    }
}

extension WebBrowserToolbarController: TabsObserver {
    func didSelect(index: Int, content: Tab.ContentType) {
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
