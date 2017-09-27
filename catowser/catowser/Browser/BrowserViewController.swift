//
//  BrowserViewController.swift
//  catowser
//
//  Created by Andrey Ermoshin on 27/09/2017.
//  Copyright © 2017 andreiermoshin. All rights reserved.
//

import UIKit

class BrowserViewController: BaseViewController {
    
    public var viewModel: BrowserViewModel?
    
    private let webContentBackgroundView: UIView = {
        let backgroundView = UIView()
        if let backColour = viewModel?.browserBackgroundColour {
            backgroundView.backgroundColor = backColour
        }
        
        return backgroundView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(webContentBackgroundView)
        webContentBackgroundView.snp.makeConstraints { (maker) in
            maker.top.equalTo(stackViewScrollableContainer.snp.bottom)
            maker.leading.equalTo(view).offset(0)
            maker.trailing.equalTo(view).offset(0)
            maker.bottom.equalTo(view).offset(0)
        }
    }
}
