//
//  TabletSearchBarViewController.swift
//  catowser
//
//  Created by admin on 19/02/2018.
//  Copyright © 2018 andreiermoshin. All rights reserved.
//

import UIKit

class TabletSearchBarViewController: BaseViewController, SearchBarControllerInterface {

    let searchBarViewController = SearchBarBaseViewController()
    
    lazy var goBackButton: UIButton = {
        let btn = UIButton()
        let img = UIImage(named: "nav-back")
        btn.setImage(img, for: .normal)
        return btn
    }()
    
    lazy var goForwardButton: UIButton = {
        let btn = UIButton()
        let img = UIImage(named: "nav-forward")
        btn.setImage(img, for: .normal)
        return btn
    }()
    
    lazy var reloadButton: UIButton = {
        let btn = UIButton()
        let img = UIImage(named: "nav-refresh")
        btn.setImage(img, for: .normal)
        return btn
    }()
    
    lazy var settingsButton: UIButton = {
        let btn = UIButton()
        let img = UIImage(named: "nav-menu")
        btn.setImage(img, for: .normal)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIConstants.searchBarBackgroundColour
        
        view.addSubview(goBackButton)
        view.addSubview(goForwardButton)
        view.addSubview(reloadButton)
        add(asChildViewController: searchBarViewController, to:view)
        // view.addSubview(settingsButton)
        
        goBackButton.snp.makeConstraints { (maker) in
            maker.leading.equalTo(0)
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
        searchBarViewController.view.snp.makeConstraints { (maker) in
            maker.leading.equalTo(reloadButton.snp.trailing)
            maker.top.equalTo(0)
            maker.bottom.equalTo(0)
            maker.trailing.equalTo(0)
        }
//        settingsButton.snp.makeConstraints { (maker) in
//            maker.leading.equalTo(searchBarViewController.view.snp.trailing)
//            maker.top.equalTo(0)
//            maker.bottom.equalTo(0)
//            maker.width.equalTo(view.snp.height)
//        }
    }
    
    func isBlank() -> Bool {
        return true
    }
}
