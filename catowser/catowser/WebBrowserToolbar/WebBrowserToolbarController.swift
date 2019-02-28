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

final class WebBrowserToolbarController: BaseViewController {

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
        barItems.append(settingsButton)
        toolbar.setItems(barItems, animated: false)
        return toolbar
    }()
    
    private let backButton: UIBarButtonItem = {
        let img = UIImage(named: "nav-back")
        let btn = UIBarButtonItem(image: img, style: .plain, target: self, action: .back)
        btn.isEnabled = false
        return btn
    }()
    
    private let forwardButton: UIBarButtonItem = {
        let img = UIImage(named: "nav-forward")
        let btn = UIBarButtonItem(image: img, style: .plain, target: self, action: .forward)
        btn.isEnabled = false
        return btn
    }()
    
    private let reloadButton: UIBarButtonItem = {
        let img = UIImage(named: "nav-refresh")
        let btn = UIBarButtonItem(image: img, style: .plain, target: self, action: .reload)
        btn.isEnabled = false
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
    
    private let settingsButton: UIBarButtonItem = {
        let img = UIImage(named: "nav-menu")
        let btn = UIBarButtonItem(image: img, style: .plain, target: self, action: .settings)
        btn.isEnabled = false
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
            }
        }
    }
}

private extension WebBrowserToolbarController {
    @objc func handleBackPressed() {

    }

    @objc func handleForwardPressed() {

    }

    @objc func handleReloadPressed() {

    }

    @objc func handleShowOpenedTabsPressed() {
        router.showTabs()
    }

    @objc func handleSettingsPressed() {

    }
}

fileprivate extension Selector {
    static let back = #selector(WebBrowserToolbarController.handleBackPressed)
    static let forward = #selector(WebBrowserToolbarController.handleForwardPressed)
    static let reload = #selector(WebBrowserToolbarController.handleReloadPressed)
    static let openTabs = #selector(WebBrowserToolbarController.handleShowOpenedTabsPressed)
    static let settings = #selector(WebBrowserToolbarController.handleSettingsPressed)
}

extension CounterView: TabsObserver {
    func update(with tabsCount: Int) {
        self.digit = tabsCount
    }
}
