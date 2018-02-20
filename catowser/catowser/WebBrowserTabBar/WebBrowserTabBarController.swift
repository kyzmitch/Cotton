//
//  WebBrowserTabBarController.swift
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

class WebBrowserTabBarController: BaseViewController {

    private lazy var toolbarView: UIToolbar = {
        let toolbar = UIToolbar()
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
    
    private lazy var backButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(barButtonSystemItem: .undo, target: self, action: #selector(handleBackPressed))
        return btn
    }()
    
    private lazy var forwardButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(barButtonSystemItem: .redo, target: self, action: #selector(handleForwardPressed))
        return btn
    }()
    
    private lazy var reloadButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(handleReloadPressed))
        return btn
    }()
    
    private lazy var openedTabsButton: UIBarButtonItem = {
        // TODO: need to transfer number of opened tabs here somehow
        let count = 0
        let btn = UIBarButtonItem(title: "\(count)", style: .plain, target: self, action: #selector(handleShowOpenedTabsPressed))
        return btn
    }()
    
    private lazy var settingsButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(handleSettingsPressed))
        return btn
    }()
    
    @objc private func handleBackPressed() {
        
    }
    
    @objc private func handleForwardPressed() {
        
    }
    
    @objc private func handleReloadPressed() {
        
    }
    
    @objc private func handleShowOpenedTabsPressed() {
        
    }
    
    @objc private func handleSettingsPressed() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(toolbarView)
        
        toolbarView.snp.makeConstraints { (maker) in
            maker.leading.equalTo(view)
            maker.trailing.equalTo(view)
            maker.top.equalTo(view)
            maker.bottom.equalTo(view)
        }
    }
}
