//
//  MasterBrowserViewController.swift
//  catowser
//
//  Created by Andrey Ermoshin on 27/09/2017.
//  Copyright © 2017 andreiermoshin. All rights reserved.
//

import UIKit

class MasterBrowserViewController: BaseViewController {

    private lazy var tabsViewController: TabsViewController = {
        let viewModel = TabsViewModel()
        let viewController = TabsViewController()
        viewController.viewModel = viewModel
        // Add View Controller as Child View Controller
        add(asChildViewController: viewController)
        
        return viewController
    }()
    
    private lazy var browserViewController: BrowserViewController = {
        let viewModel = BrowserViewModel()
        let viewController = BrowserViewController()
        viewController.viewModel = viewModel
        // Add View Controller as Child View Controller
        add(asChildViewController: viewController)
        
        return viewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    private func add(asChildViewController viewController: UIViewController) {
        // Add Child View Controller
        addChildViewController(viewController)
        
        // Add Child View as Subview
        view.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParentViewController: self)
    }

}
