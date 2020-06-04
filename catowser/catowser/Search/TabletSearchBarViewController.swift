//
//  TabletSearchBarViewController.swift
//  catowser
//
//  Created by admin on 19/02/2018.
//  Copyright © 2018 andreiermoshin. All rights reserved.
//

import UIKit
import CoreBrowser

final class TabletSearchBarViewController: BaseViewController {

    private let searchBarViewController: SearchBarBaseViewController

    /// Site navigation delegate. It is always `nil` during initialization because no active web view is present
    private weak var siteNavigationDelegate: SiteNavigationDelegate? {
        didSet {
            guard siteNavigationDelegate != nil else {
                actionsButton.isEnabled = false
                goBackButton.isEnabled = false
                goForwardButton.isEnabled = false
                reloadButton.isEnabled = false
                return
            }

            // this will be useful when user will change current web view
            reloadNavigationElements(true)
        }
    }
    
    init(_ searchBarDelegate: UISearchBarDelegate) {
        searchBarViewController = SearchBarBaseViewController(searchBarDelegate)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var actionsButton: UIButton = {
        let btn: UIButton
        if #available(iOS 13.0, *) {
            if let systemImage = UIImage.arropUp {
                btn = UIButton()
                btn.setImage(systemImage, for: .normal)
                btn.addTarget(self, action: .actionsPressed, for: .touchUpInside)
            } else {
                btn = .systemButton(with: .actions, target: self, action: .actionsPressed)
            }
        } else {
            btn = UIButton(type: .infoLight)
            btn.addTarget(self, action: .actionsPressed, for: .touchUpInside)
        }
        btn.backgroundColor = ThemeProvider.shared.theme.searchBarButtonBackgroundColor
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private lazy var goBackButton: UIButton = {
        let btn = UIButton()
        let img = UIImage(named: "nav-back")
        btn.backgroundColor = ThemeProvider.shared.theme.searchBarButtonBackgroundColor
        btn.setImage(img, for: .normal)
        btn.addTarget(self, action: .backPressed, for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private lazy var goForwardButton: UIButton = {
        let btn = UIButton()
        let img = UIImage(named: "nav-forward")
        btn.backgroundColor = ThemeProvider.shared.theme.searchBarButtonBackgroundColor
        btn.setImage(img, for: .normal)
        btn.addTarget(self, action: .forwardPressed, for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private lazy var reloadButton: UIButton = {
        let btn = UIButton()
        let img = UIImage(named: "nav-refresh")
        btn.backgroundColor = ThemeProvider.shared.theme.searchBarButtonBackgroundColor
        btn.setImage(img, for: .normal)
        btn.addTarget(self, action: .reloadPressed, for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeProvider.shared.theme.searchBarSeparatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func loadView() {
        view = UIView()
        
        view.addSubview(actionsButton)
        view.addSubview(goBackButton)
        view.addSubview(goForwardButton)
        view.addSubview(reloadButton)
        add(asChildViewController: searchBarViewController, to: view)
        view.addSubview(lineView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // disabled after `init` because no web view is present
        actionsButton.isEnabled = false
        goBackButton.isEnabled = false
        goForwardButton.isEnabled = false
        reloadButton.isEnabled = false

        view.backgroundColor = UIConstants.searchBarBackgroundColour
        
        actionsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        actionsButton.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        actionsButton.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        actionsButton.widthAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        goBackButton.leadingAnchor.constraint(equalTo: actionsButton.trailingAnchor).isActive = true
        goBackButton.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        goBackButton.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        goBackButton.widthAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        goForwardButton.leadingAnchor.constraint(equalTo: goBackButton.trailingAnchor).isActive = true
        goForwardButton.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        goForwardButton.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        goForwardButton.widthAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        reloadButton.leadingAnchor.constraint(equalTo: goForwardButton.trailingAnchor).isActive = true
        reloadButton.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        reloadButton.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        reloadButton.widthAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        searchBarViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        searchBarViewController.view.leadingAnchor.constraint(equalTo: reloadButton.trailingAnchor).isActive = true
        searchBarViewController.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        searchBarViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        searchBarViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        lineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        lineView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        lineView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        lineView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    @objc fileprivate func actionsPressed() {
        let sourceRect = actionsButton.frame
        siteNavigationDelegate?.openTabMenu(from: view, and: sourceRect)
    }

    @objc fileprivate func backPressed() {
        siteNavigationDelegate?.goBack()
        refreshNavigation()
    }

    @objc fileprivate func forwardPressed() {
        siteNavigationDelegate?.goForward()
        refreshNavigation()
    }
    
    @objc fileprivate func reloadPressed() {
        siteNavigationDelegate?.reload()
    }
    
    private func refreshNavigation() {
        actionsButton.isEnabled = siteNavigationDelegate != nil
        goBackButton.isEnabled = siteNavigationDelegate?.canGoBack ?? false
        goForwardButton.isEnabled = siteNavigationDelegate?.canGoForward ?? false
    }
}

extension TabletSearchBarViewController: SiteNavigationComponent {
    func changeBackButton(to canGoBack: Bool) {
        goBackButton.isEnabled = canGoBack
    }
    
    func changeForwardButton(to canGoForward: Bool) {
        goForwardButton.isEnabled = canGoForward
    }
    
    var siteNavigator: SiteNavigationDelegate? {
        get {
            return siteNavigationDelegate
        }
        set (newValue) {
            siteNavigationDelegate = newValue
        }
    }

    func reloadNavigationElements(_ withSite: Bool, downloadsAvailable: Bool = false) {
        goBackButton.isEnabled = siteNavigationDelegate?.canGoBack ?? false
        goForwardButton.isEnabled = siteNavigationDelegate?.canGoForward ?? false
        reloadButton.isEnabled = withSite
        // show actions even for non site state to be able to
        // get to global settings
        actionsButton.isEnabled = true

        // tablet layout currently doesn't have downloads button
    }
}

extension TabletSearchBarViewController: AnyViewController {}

extension TabletSearchBarViewController: SearchBarControllerInterface {
    func changeState(to state: SearchBarState, animated: Bool) {
        searchBarViewController.changeState(to: state, animated: animated)
    }
}

fileprivate extension Selector {
    static let backPressed = #selector(TabletSearchBarViewController.backPressed)
    static let forwardPressed = #selector(TabletSearchBarViewController.forwardPressed)
    static let reloadPressed = #selector(TabletSearchBarViewController.reloadPressed)
    static let actionsPressed = #selector(TabletSearchBarViewController.actionsPressed)
}
