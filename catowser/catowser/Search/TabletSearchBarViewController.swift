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
            if let systemImage = UIImage(systemName: "square.and.arrow.up") {
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
        return btn
    }()
    
    private lazy var goBackButton: UIButton = {
        let btn = UIButton()
        let img = UIImage(named: "nav-back")
        btn.backgroundColor = ThemeProvider.shared.theme.searchBarButtonBackgroundColor
        btn.setImage(img, for: .normal)
        btn.addTarget(self, action: .backPressed, for: .touchUpInside)
        return btn
    }()
    
    private lazy var goForwardButton: UIButton = {
        let btn = UIButton()
        let img = UIImage(named: "nav-forward")
        btn.backgroundColor = ThemeProvider.shared.theme.searchBarButtonBackgroundColor
        btn.setImage(img, for: .normal)
        btn.addTarget(self, action: .forwardPressed, for: .touchUpInside)
        return btn
    }()
    
    private lazy var reloadButton: UIButton = {
        let btn = UIButton()
        let img = UIImage(named: "nav-refresh")
        btn.backgroundColor = ThemeProvider.shared.theme.searchBarButtonBackgroundColor
        btn.setImage(img, for: .normal)
        btn.addTarget(self, action: .reloadPressed, for: .touchUpInside)
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
        
        actionsButton.snp.makeConstraints { (maker) in
            maker.leading.equalTo(0)
            maker.top.equalTo(0)
            maker.bottom.equalTo(0)
            maker.width.equalTo(view.snp.height)
        }
        
        goBackButton.snp.makeConstraints { (maker) in
            maker.leading.equalTo(actionsButton.snp.trailing)
            maker.top.equalTo(0)
            maker.bottom.equalTo(0)
            maker.width.equalTo(view.snp.height)
        }
        goForwardButton.snp.makeConstraints { (maker) in
            maker.leading.equalTo(goBackButton.snp.trailing)
            maker.top.equalTo(0)
            maker.bottom.equalTo(0)
            maker.width.equalTo(view.snp.height)
        }
        reloadButton.snp.makeConstraints { (maker) in
            maker.leading.equalTo(goForwardButton.snp.trailing)
            maker.top.equalTo(0)
            maker.bottom.equalTo(0)
            maker.width.equalTo(view.snp.height)
        }
        
        searchBarViewController.view.translatesAutoresizingMaskIntoConstraints = false
        searchBarViewController.view.snp.makeConstraints { (maker) in
            maker.leading.equalTo(reloadButton.snp.trailing)
            maker.top.equalTo(0)
            maker.bottom.equalTo(0)
            maker.trailing.equalTo(0)
        }

        lineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        lineView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        lineView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        lineView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
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
        // Actions are only for web sites, other settings will be in global settings
        actionsButton.isEnabled = withSite

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
