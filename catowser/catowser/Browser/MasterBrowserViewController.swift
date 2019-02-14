//
//  MasterBrowserViewController.swift
//  catowser
//
//  Created by Andrey Ermoshin on 27/09/2017.
//  Copyright © 2017 andreiermoshin. All rights reserved.
//

import UIKit
import ReactiveSwift

/// The sate of search bar
enum SearchBarState {
    /// keyboard is hidden
    case clear
    /// keyboard is visible
    case readyForInput
}

protocol SearchBarControllerInterface: class {
    func isBlank() -> Bool
    func stateChanged(to state: SearchBarState)
}

/// An interface for component which suppose to render tabs
///
/// Class protocol is used because object gonna be stored by `weak` ref
/// `AnyObject` is new name for it, but will use old one to find when XCode
/// will start mark it as deprecated.
/// https://forums.swift.org/t/class-only-protocols-class-vs-anyobject/11507/4
protocol TabRendererInterface: AnyViewController {
    func open(tab: Tab)
}

final class MasterBrowserViewController: BaseViewController {

    init(_ viewModel: MasterBrowserViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let viewModel: MasterBrowserViewModel
    
    /// Tabs list without previews. Needed only for tablets or landscape mode.
    private lazy var tabsViewController: TabsViewController = {
        let vm = TabsViewModel()
        let viewController = TabsViewController()
        viewController.viewModel = vm
        
        return viewController
    }()
    
    private lazy var searchBarController: UIViewController & SearchBarControllerInterface = {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return TabletSearchBarViewController(self)
        } else {
            return SmartphoneSearchBarViewController(self)
        }
    }()

    /// The view controller to manage blank tab, possibly will be enhaced
    /// to support favorite sites list.
    private let blankWebPageController = BlankWebPageViewController()

    /// The view needed to hold tab content like WebView or favorites table view.
    private let containerView = UIView()

    /// The controller for toolbar buttons. Used only for compact sizes/smartphones.
    private lazy var toolbarViewController: WebBrowserToolbarController = {
        let router = ToolbarRouter(presenter: self)
        let toolbar = WebBrowserToolbarController(router: router)
        return toolbar
    }()

    /// The current holder for WebView (controller) if browser has at least one
    private var currentWebViewController: WebViewController?

    private var disposables = [Disposable?]()
    
    override func loadView() {
        // Your custom implementation of this method should not call super.
        view = UIView()
        
        // In that method, create your view hierarchy programmatically and assign
        // the root view of that hierarchy to the view controller’s view property.
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            add(asChildViewController: tabsViewController, to:view)
        }
        
        add(asChildViewController: searchBarController, to:view)
        view.addSubview(containerView)
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            add(asChildViewController: toolbarViewController, to:view)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        let tabsControllerAdded = UIDevice.current.userInterfaceIdiom == .pad ? true : false
        
        if tabsControllerAdded {
            tabsViewController.view.snp.makeConstraints { (maker) in
                // https://github.com/SnapKit/SnapKit/issues/448
                // https://developer.apple.com/documentation/uikit/uiviewcontroller/1621367-toplayoutguide
                // https://developer.apple.com/documentation/uikit/uiview/2891102-safearealayoutguide
                
                if #available(iOS 11, *) {
                    maker.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
                } else {
                    maker.top.equalTo(view)
                }
                
                maker.leading.equalTo(view)
                maker.trailing.equalTo(view)
                maker.height.equalTo(viewModel.topViewPanelHeight)
            }
            
            searchBarController.view.snp.makeConstraints({ (maker) in
                maker.top.equalTo(tabsViewController.view.snp.bottom)
                maker.leading.equalTo(view)
                maker.trailing.equalTo(view)
                maker.height.equalTo(UIConstants.searchViewHeight)
            })
            
            // Need to have not simple view controller view but container view
            // to have ability to insert to it and show view controller with
            // bookmarks in case if search bar has no any address entered or
            // webpage controller with web view if some address entered in search bar
            containerView.snp.makeConstraints { (maker) in
                maker.top.equalTo(searchBarController.view.snp.bottom)
                maker.leading.equalTo(view)
                maker.trailing.equalTo(view)
                if #available(iOS 11, *) {
                    maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
                } else {
                    maker.bottom.equalTo(view)
                }
            }
        } else {
            searchBarController.view.snp.makeConstraints({ (maker) in
                if #available(iOS 11, *) {
                    maker.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
                } else {
                    maker.top.equalTo(view)
                }
                
                maker.leading.equalTo(view)
                maker.trailing.equalTo(view)
                maker.height.equalTo(UIConstants.searchViewHeight)
            })
            
            containerView.snp.makeConstraints { (maker) in
                maker.top.equalTo(searchBarController.view.snp.bottom)
                maker.bottom.equalTo(toolbarViewController.view.snp.top)
                maker.leading.equalTo(view)
                maker.trailing.equalTo(view)
            }
            
            toolbarViewController.view.snp.makeConstraints({ (maker) in
                maker.top.equalTo(containerView.snp.bottom)
                maker.leading.equalTo(0)
                maker.trailing.equalTo(0)
                maker.height.equalTo(UIConstants.tabBarHeight)
                
                if #available(iOS 11, *) {
                    maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
                } else {
                    maker.bottom.equalTo(view)
                }
            })
        }

        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil, using: keyboardWillHideClosure())

        let disposeA = NotificationCenter.default.reactive
            .notifications(forName: UIResponder.keyboardWillChangeFrameNotification)
            .observe(on: UIScheduler())
            .observeValues {[weak self] notification in
                self?.keyboardWillChangeFrameClosure()(notification)
        }

        disposables.append(disposeA)

        if let currentTab = try? TabsListManager.shared.selectedTab() {
            open(tab: currentTab)
        } else {
            let firstTab = Tab(contentType: DefaultTabProvider.shared.contentState, selected: true)
            open(tab: firstTab)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return ThemeProvider.shared.theme.statusBarStyle
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }

    deinit {
        disposables.forEach { $0?.dispose() }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension MasterBrowserViewController: TabRendererInterface {
    func open(tab: Tab) {
        print("\(#function)")

        switch tab.contentType {
        case .site(let site):
            guard let webViewController = try? WebViewsReuseManager.shared.getControllerFor(site) else {
                return
            }
            removeCurrentWebView()
            add(asChildViewController: webViewController, to: containerView)
            webViewController.view.snp.makeConstraints { make in
                make.left.right.top.bottom.equalTo(containerView)
            }
        default:
            removeCurrentWebView()
            add(asChildViewController: blankWebPageController, to: containerView)
            blankWebPageController.view.snp.makeConstraints { maker in
                maker.left.right.top.bottom.equalTo(containerView)
            }
            break
        }
    }

    private func removeCurrentWebView() {
        if let previousWebViewController = currentWebViewController {
            previousWebViewController.willMove(toParent: nil)
            previousWebViewController.removeFromParent()
            // remove view and constraints
            previousWebViewController.view.removeFromSuperview()
        }
    }
}

extension MasterBrowserViewController {
    private func keyboardWillChangeFrameClosure() -> (Notification) -> Void {
        func handling(_ notification: Notification) {
            guard let info = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] else { return }
            guard let value = info as? NSValue else { return }
            let rect = value.cgRectValue
            
            print("\(#function): keyboard will show with height \(rect.size.height)")
            
        }
        
        return handling
    }
    
    private func keyboardWillHideClosure() -> (Notification) -> Void {
        func handling(_ notification: Notification) {
            print("\(#function): keyboard will hide")
            
        }
        
        return handling
    }
}

extension MasterBrowserViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            // hideSearchController()
        } else {
            // showSearchController()
            SearchSuggestClient.shared.constructSuggestions(basedOn: searchText)
        }
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // need to free space to show `cancel` button for search bar on smartPhone
        searchBarController.stateChanged(to: .readyForInput)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        endSearch(for: searchBar)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        endSearch(for: searchBar)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        endSearch(for: searchBar)
    }

    private func endSearch(for searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBarController.stateChanged(to: .clear)
    }
}
