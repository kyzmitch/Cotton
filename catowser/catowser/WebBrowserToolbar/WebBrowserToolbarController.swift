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

final class WebBrowserToolbarController<C: Navigating>: BaseViewController where C.R == ToolbarRoute {
    private weak var coordinator: C?
    /// download panel delegate
    private weak var downloadPanelDelegate: DownloadPanelPresenter?
    /// web view interface
    private weak var webViewInterface: WebViewNavigatable? {
        didSet {
            guard webViewInterface != nil else {
                toolbarView.state = .nothingToNavigate
                return
            }
            toolbarView.webViewInterface = webViewInterface
            toolbarView.state = .readyForNavigation
        }
    }
    
    private let toolbarView: WebBrowserToolbarView

    init(_ coordinator: C?,
         _ downloadPanelDelegate: DownloadPanelPresenter?,
         _ globalSettingsDelegate: GlobalMenuDelegate?) {
        self.coordinator = coordinator
        self.downloadPanelDelegate = downloadPanelDelegate
        toolbarView = WebBrowserToolbarView(frame: .zero)
        toolbarView.globalSettingsDelegate = globalSettingsDelegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
    }

    override func loadView() {
        view = toolbarView
        ThemeProvider.shared.setup(toolbarView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toolbarView.translatesAutoresizingMaskIntoConstraints = false
        toolbarView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        toolbarView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        toolbarView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        toolbarView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Workaround for UIBarButtonItem with a custom UIView
        // for strange reason it can't recognize gesture recognizers or
        // even target-action for this specific view
        for touch in touches {
            if touch.view == toolbarView.counterView {
                handleShowOpenedTabsPressed()
                break
            } else if touch.view == toolbarView.downloadsView {
                handleDownloadsPressed()
                break
            }
        }
    }
    
    // MARK: - private functions
    
    @objc private func handleShowOpenedTabsPressed() {
        coordinator?.showNext(.tabs)
    }
    
    private func handleDownloadsPressed() {
        guard toolbarView.state.downloadsAvailable else {
            return
        }
        toolbarView.state = .downloadsTapped
        downloadPanelDelegate?.didPressDownloads(to: false)
    }
}

extension WebBrowserToolbarController: FullSiteNavigationComponent {
    func changeBackButton(to canGoBack: Bool) {
        let prevState = toolbarView.state
        toolbarView.state = .updateBackState(canGoBack)
        toolbarView.state = prevState
    }
    
    func changeForwardButton(to canGoForward: Bool) {
        let prevState = toolbarView.state
        toolbarView.state = .updateForwardState(canGoForward)
        toolbarView.state = prevState
    }
    
    func reloadNavigationElements(_ withSite: Bool, downloadsAvailable: Bool = false) {
        switch (withSite, downloadsAvailable) {
        case (false, _):
            toolbarView.state = .nothingToNavigate
        case (true, false):
            toolbarView.state = .readyForNavigation
        case (true, true):
            toolbarView.state = .readyForDownloads
        }
    }

    var siteNavigator: WebViewNavigatable? {
        get {
            return webViewInterface
        }
        set (newValue) {
            webViewInterface = newValue
        }
    }
}
