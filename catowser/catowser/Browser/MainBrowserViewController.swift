//
//  MainBrowserViewController.swift
//  catowser
//
//  Created by Andrey Ermoshin on 27/09/2017.
//  Copyright © 2017 andreiermoshin. All rights reserved.
//

import UIKit

final class MainBrowserViewController<C: Navigating & Layouting>: BaseViewController
    where C.R == MainScreenRoute, C.SP == MainScreenSubview {
    /// Define a specific type of coordinator, because not any coordinator
    /// can be used for this specific view controller
    /// and also the routes are specific to this screen as well.
    /// Storing it by weak reference, it is stored strongly in the coordinator owner
    private weak var coordinator: C?
    
    // MARK: - initializers
    
    init(_ coordinator: C) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        // was in `viewWillDisappear` before
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Overrided functions from base type
    
    override func loadView() {
        // Your custom implementation of this method should not call super.
        view = UIView()
        
        guard let superView = coordinator else {
            return
        }
        // In that method, create your view hierarchy programmatically and assign
        // the root view of that hierarchy to the view controller’s view property.
        
        if isPad {
            superView.insertNext(.tabs)
        }
        superView.insertNext(.searchBar)
        superView.insertNext(.loadingProgress)
        superView.insertNext(.webContentContainer)
        // Files grid needs to be added even on Tablet layout,
        // also, it needs to be added before link tags
        // to make link tags frontmost
        superView.insertNext(.filesGrid)
        // should be added before iPhone toolbar
        superView.insertNext(.linkTags)
        if !isPad {
            superView.insertNext(.toolbar)
        }
        superView.insertNext(.dummyView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        
        guard let layoutHandler = coordinator else {
            return
        }
        // Layout order matters!
        
        // Next sequence of calls could be replaced with just one method:
        // `coordinator?.layout(.viewDidLoad())`
        // but then all this logic should be moved to coordinator
        
        if isPad {
            layoutHandler.layoutNext(.viewDidLoad(.tabs))
        }
        layoutHandler.layoutNext(.viewDidLoad(.searchBar))
        layoutHandler.layoutNext(.viewDidLoad(.loadingProgress))
        layoutHandler.layoutNext(.viewDidLoad(.webContentContainer))
        if !isPad {
            layoutHandler.layoutNext(.viewDidLoad(.toolbar))
        }
        layoutHandler.layoutNext(.viewDidLoad(.dummyView))
        if !isPad {
            // Link tags view won't be inserted on Tablets
            // but will be presented as a popover
            layoutHandler.layoutNext(.viewDidLoad(.linkTags))
            // Files grid is started on Tablet as well
            // not to insert it as a subview but to init vc
            layoutHandler.layoutNext(.viewDidLoad(.filesGrid))
        }
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()

        if isPad {
            coordinator?.layoutNext(.viewSafeAreaInsetsDidChange(.dummyView))
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !isPad {
            coordinator?.layoutNext(.viewDidLayoutSubviews(.filesGrid))
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return ThemeProvider.shared.theme.statusBarStyle
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
