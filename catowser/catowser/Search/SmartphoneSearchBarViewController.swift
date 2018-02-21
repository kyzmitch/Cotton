//
//  SmartphoneSearchBarViewController.swift
//  catowser
//
//  Created by admin on 19/02/2018.
//  Copyright © 2018 andreiermoshin. All rights reserved.
//

import UIKit

class SmartphoneSearchBarViewController: BaseViewController, SearchBarControllerInterface {

    let searchBarViewController = SearchBarBaseViewController()
    
    lazy var goBackButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = UIColor.white
        let img = UIImage(named: "goBack")
        btn.setImage(img, for: .normal)
        
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(goBackButton)
        add(asChildViewController: searchBarViewController, to:view)
        
        goBackButton.snp.makeConstraints { (maker) in
            maker.leading.equalTo(0)
            maker.top.equalTo(0)
            maker.bottom.equalTo(0)
            maker.width.equalTo(view.snp.height)
        }
        
        searchBarViewController.view.snp.makeConstraints { (maker) in
            maker.leading.equalTo(goBackButton.snp.trailing)
            maker.top.equalTo(0)
            maker.bottom.equalTo(0)
            maker.trailing.equalTo(0)
        }
    }

    func isBlank() -> Bool {
        return true
    }
}
