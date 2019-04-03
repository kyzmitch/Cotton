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

final class WebBrowserToolbarController: BaseViewController {

    /// Site navigation delegate
    private weak var siteNavigationDelegate: SiteNavigationDelegate? {
        didSet {
            guard let _ = siteNavigationDelegate else {
                backButton.isEnabled = false
                forwardButton.isEnabled = false
                hideDownloads = true
                downloadLinksButton.isEnabled = false
                return
            }

            reloadNavigationElements(false)
        }
    }

    weak var delegate: DonwloadPanelDelegate?

    fileprivate var hideDownloads: Bool = true {
        didSet {
            animateDownloadsButton(hideDownloads)
        }
    }

    private lazy var toolbarView: UIToolbar = {
        let toolbar = UIToolbar()

        ThemeProvider.shared.setup(toolbar)
        
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
        let space4 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        barItems.append(space4)
        barItems.append(downloadLinksButton)
        toolbar.setItems(barItems, animated: false)
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

    private let counterView: CounterView = CounterView(frame: .zero)
    
    private lazy var openedTabsButton: UIBarButtonItem = {
        counterView.digit = TabsListManager.shared.tabsCount
        TabsListManager.shared.attach(counterView)
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
        // TODO: need to make custom image view grayed when UIBarButtonItem is not enabled
        return btn
    }()

    private let router: ToolbarRouter

    init(router: ToolbarRouter) {
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }

    deinit {
        TabsListManager.shared.detach(counterView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = UIView()
        
        view.addSubview(toolbarView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // disabled after `init` because no web view is present
        backButton.isEnabled = false
        forwardButton.isEnabled = false
        reloadButton.isEnabled = false

        toolbarView.snp.makeConstraints { (maker) in
            maker.left.right.top.bottom.equalTo(view)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Workaround for UIBarButtonItem with a custom UIView
        // for strange reason it can't recognize gesture recognizers or
        // even target-action for this specific view
        for touch in touches {
            if touch.view == counterView {
                handleShowOpenedTabsPressed()
            } else if touch.view == downloadsView {
                handleDownloadsPressed()
            }
        }
    }
}

extension WebBrowserToolbarController: SiteNavigationComponent {
    func updateSiteNavigator(to navigator: SiteNavigationDelegate?) {
        siteNavigationDelegate = navigator
    }

    func reloadNavigationElements(_ withSite: Bool, downloadsAvailable: Bool = false) {
        // this will be useful when user will change current web view
        backButton.isEnabled = siteNavigationDelegate?.canGoBack ?? false
        forwardButton.isEnabled = siteNavigationDelegate?.canGoForward ?? false
        reloadButton.isEnabled = withSite
        hideDownloads = true
        downloadLinksButton.isEnabled = downloadsAvailable
    }
}

private extension WebBrowserToolbarController {
    @objc func handleBackPressed() {
        siteNavigationDelegate?.goBack()
    }

    @objc func handleForwardPressed() {
        siteNavigationDelegate?.goForward()
    }

    @objc func handleReloadPressed() {
        siteNavigationDelegate?.reload()
    }

    @objc func handleShowOpenedTabsPressed() {
        router.showTabs()
    }

    @objc func handleDownloadsPressed() {
        hideDownloads = !hideDownloads
        delegate?.didPressDownloads(to: hideDownloads)
    }

    func animateDownloadsButton(_ arrowDown: Bool) {
        let rotate = UIViewPropertyAnimator(duration: 0.33, curve: .easeIn)
        rotate.addAnimations {
            let angle = arrowDown ? CGFloat.pi : 0
            self.downloadsView.transform = CGAffineTransform(rotationAngle: angle)
        }
        rotate.startAnimation()
    }
}

fileprivate extension Selector {
    static let back = #selector(WebBrowserToolbarController.handleBackPressed)
    static let forward = #selector(WebBrowserToolbarController.handleForwardPressed)
    static let reload = #selector(WebBrowserToolbarController.handleReloadPressed)
    static let openTabs = #selector(WebBrowserToolbarController.handleShowOpenedTabsPressed)
    static let downloads = #selector(WebBrowserToolbarController.handleDownloadsPressed)
}

extension CounterView: TabsObserver {
    func update(with tabsCount: Int) {
        self.digit = tabsCount
    }
}
