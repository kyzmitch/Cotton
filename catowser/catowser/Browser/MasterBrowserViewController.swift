//
//  MasterBrowserViewController.swift
//  catowser
//
//  Created by Andrey Ermoshin on 27/09/2017.
//  Copyright © 2017 andreiermoshin. All rights reserved.
//

import UIKit

protocol SearchBarControllerInterface: class {
    func isBlank() -> Bool
}

class MasterBrowserViewController: BaseViewController {

    var viewModel: MasterBrowserViewModel?
    
    // Needed only for ipads
    private lazy var tabsViewController: TabsViewController = {
        var tabsViewModel: TabsViewModel
        if let vm = viewModel {
            tabsViewModel = TabsViewModel(vm.topViewsOffset, vm.topViewPanelHeight)
        }
        else {
            tabsViewModel = TabsViewModel()
        }
        let viewController = TabsViewController()
        viewController.viewModel = tabsViewModel
        
        return viewController
    }()
    
    private lazy var searchBarController: UIViewController & SearchBarControllerInterface = {
        
        let searchSuggestClient = SearchClientsFactory.searchSuggestClient(of: .Google, handler: { (result) in
            
        })
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            return TabletSearchBarViewController(searchSuggestClient)
        }
        else {
            return SmartphoneSearchBarViewController(searchSuggestClient)
        }
    }()
    
    private lazy var blankWebPageController: BlankWebPageViewController = {
        let viewController = BlankWebPageViewController()
        
        return viewController
    }()
    
    private lazy var webSiteContainerView: UIView = {
        let container = UIView()
        return container
    }()
    
    private lazy var toolbarViewController: WebBrowserToolbarController = {
        let toolbar = WebBrowserToolbarController()
        return toolbar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var tabsControllerAdded = false
        if UIDevice.current.userInterfaceIdiom == .pad {
            tabsControllerAdded = true
            add(asChildViewController: tabsViewController, to:view)
        }
        
        add(asChildViewController: searchBarController, to:view)
        view.addSubview(webSiteContainerView)
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            add(asChildViewController: toolbarViewController, to:view)
        }
        
        add(asChildViewController: blankWebPageController, to:webSiteContainerView)
        
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
                if let vm = viewModel {
                    maker.height.equalTo(vm.topViewPanelHeight)
                }
                else {
                    maker.height.equalTo(UIConstants.tabHeight)
                }
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
            webSiteContainerView.snp.makeConstraints { (maker) in
                maker.top.equalTo(searchBarController.view.snp.bottom)
                maker.leading.equalTo(view)
                maker.trailing.equalTo(view)
                if #available(iOS 11, *) {
                    maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
                } else {
                    maker.bottom.equalTo(view)
                }
            }
        }
        else {
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
            
            webSiteContainerView.snp.makeConstraints { (maker) in
                maker.top.equalTo(searchBarController.view.snp.bottom)
                maker.bottom.equalTo(toolbarViewController.view.snp.top)
                maker.leading.equalTo(view)
                maker.trailing.equalTo(view)
            }
            
            toolbarViewController.view.snp.makeConstraints({ (maker) in
                maker.top.equalTo(webSiteContainerView.snp.bottom)
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
        
        blankWebPageController.view.snp.makeConstraints { (make) in
            make.leading.equalTo(webSiteContainerView)
            make.trailing.equalTo(webSiteContainerView)
            make.top.equalTo(webSiteContainerView)
            make.bottom.equalTo(webSiteContainerView)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(forName: Notification.Name.UIKeyboardWillChangeFrame, object: nil, queue: nil, using: keyboardWillChangeFrameClosure())
        NotificationCenter.default.addObserver(forName: Notification.Name.UIKeyboardWillHide, object: nil, queue: nil, using: keyboardWillHideClosure())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
}

extension MasterBrowserViewController {
    private func keyboardWillChangeFrameClosure() -> (Notification) -> Void {
        func handling(_ notification: Notification) {
            guard let info = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] else { return }
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
