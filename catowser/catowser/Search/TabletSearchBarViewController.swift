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
        btn.setTitle(NSLocalizedString("ttl_btn_back", comment: "To go on previous web page"), for: .normal)
        
        return btn
    }()
    
    lazy var goForwardButton: UIButton = {
        let btn = UIButton()
        btn.setTitle(NSLocalizedString("ttl_btn_forward", comment: "To go on next web page"), for: .normal)
        
        return btn
    }()
    
    lazy var reloadButton: UIButton = {
        let btn = UIButton()
        btn.setTitle(NSLocalizedString("ttl_btn_reload", comment: "To reload web page"), for: .normal)
        
        return btn
    }()
    
    lazy var settingsButton: UIButton = {
        let btn = UIButton()
        btn.setTitle(NSLocalizedString("ttl_btn_settings", comment: "To show settings menu"), for: .normal)
        
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(goBackButton)
        view.addSubview(goForwardButton)
        view.addSubview(reloadButton)
        view.addSubview(searchBarViewController.view)
        view.addSubview(settingsButton)
        
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
            maker.trailing.equalTo(settingsButton.snp.leading)
        }
        settingsButton.snp.makeConstraints { (maker) in
            maker.leading.equalTo(searchBarViewController.view.snp.trailing)
            maker.top.equalTo(0)
            maker.bottom.equalTo(0)
            maker.width.equalTo(view.snp.height)
        }
    }
    
    func isBlank() -> Bool {
        return true
    }
}
