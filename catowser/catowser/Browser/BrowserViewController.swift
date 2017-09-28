//
//  BrowserViewController.swift
//  catowser
//
//  Created by Andrey Ermoshin on 27/09/2017.
//  Copyright © 2017 andreiermoshin. All rights reserved.
//

import UIKit

class BrowserViewController: BaseViewController {
    
    public var viewModel: BrowserViewModel? {
        willSet {
            if let vm = newValue {
                webContentBackgroundView.backgroundColor = vm.browserBackgroundColour
            }
        }
    }
    
    private let webContentBackgroundView: UIView = {
        let backgroundView = UIView()
        return backgroundView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(webContentBackgroundView)
        webContentBackgroundView.snp.makeConstraints { (maker) in
            maker.top.equalTo(view).offset(0)
            maker.leading.equalTo(view).offset(0)
            maker.trailing.equalTo(view).offset(0)
            maker.bottom.equalTo(view).offset(0)
        }
    }
}
