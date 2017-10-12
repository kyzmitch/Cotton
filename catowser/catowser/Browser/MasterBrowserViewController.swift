//
//  MasterBrowserViewController.swift
//  catowser
//
//  Created by Andrey Ermoshin on 27/09/2017.
//  Copyright © 2017 andreiermoshin. All rights reserved.
//

import UIKit

class MasterBrowserViewController: BaseViewController {

    public var viewModel: MasterBrowserViewModel?
    private let websiteAddressSearchController = WebsiteSearchControllerManager()
    private var searchBarContainerView: UIView?
    
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
    
    private lazy var browserViewController: BrowserViewController = {
        let viewModel = BrowserViewModel()
        let viewController = BrowserViewController()
        viewController.viewModel = viewModel
        
        return viewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        add(asChildViewController: tabsViewController)
        addSearchBar(from: websiteAddressSearchController.searchController)
        add(asChildViewController: browserViewController)
        
        let statusBarFrame = UIApplication.shared.statusBarFrame
        let topOffset = statusBarFrame.origin.y + statusBarFrame.size.height
        
        tabsViewController.view.snp.makeConstraints { (maker) in
            if let vm = viewModel {
                maker.height.equalTo(vm.topViewPanelHeight + topOffset)
            }
            else {
                maker.height.equalTo(UIConstants.tabHeight + topOffset)
            }
            
            maker.topMargin.equalTo(view).offset(0)
            maker.leading.equalTo(view).offset(0)
            maker.trailing.equalTo(view).offset(0)
        }
        
        searchBarContainerView?.snp.makeConstraints { (maker) in
            maker.top.equalTo(tabsViewController.view.snp.bottom).offset(0)
            maker.leading.equalTo(0)
            maker.trailing.equalTo(0)
            maker.height.equalTo(56)
        }
        
        browserViewController.view.snp.makeConstraints { (maker) in
            if let sbview = searchBarContainerView {
                maker.top.equalTo(sbview.snp.bottom).offset(0)
            }
            else {
                maker.top.equalTo(tabsViewController.view).offset(0)
            }
            maker.bottom.equalTo(0)
            maker.leading.equalTo(0)
            maker.trailing.equalTo(0)
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

    private func add(asChildViewController viewController: UIViewController) {
        // Add Child View Controller
        addChildViewController(viewController)
        
        // Add Child View as Subview
        view.addSubview(viewController.view)
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParentViewController: self)
    }
    
    private func addSearchBar(from searchController: UISearchController) {
        // ensure that the search bar does not remain on the screen
        // if the user navigates to another view controller
        // while the UISearchController is active.
        definesPresentationContext = true
        // NOTE: you should never push to navigation controller or use it as a child etc.
        // If you want that, you can use UISearchContainerViewController to wrap it first.
        // http://samwize.com/2016/11/27/uisearchcontroller-development-guide/
        let container = UISearchContainerViewController(searchController: searchController)
        addChildViewController(container)
        searchBarContainerView = container.view
        view.addSubview(container.view)
        view.bringSubview(toFront: searchController.searchBar)
        container.didMove(toParentViewController: self)
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
