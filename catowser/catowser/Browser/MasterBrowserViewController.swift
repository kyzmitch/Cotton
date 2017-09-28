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
        
        browserViewController.view.snp.makeConstraints { (maker) in
            maker.top.equalTo(tabsViewController.view.snp.bottom).offset(0)
            maker.bottom.equalTo(0)
            maker.leading.equalTo(0)
            maker.trailing.equalTo(0)
        }
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

}
