//
//  BrowserViewController.swift
//  catowser
//
//  Created by Andrey Ermoshin on 27/09/2017.
//  Copyright © 2017 andreiermoshin. All rights reserved.
//

import UIKit
import SnapKit
import WebKit

class BrowserViewController: BaseViewController {
    
    public var viewModel: BrowserViewModel?
    
    private let webContentView: WKWebView = {
        let webView = WKWebView()
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(webContentView)
        webContentView.snp.makeConstraints { (maker) in
            maker.top.equalTo(view)
            maker.leading.equalTo(view)
            maker.trailing.equalTo(view)
            maker.bottom.equalTo(view)
        }
    }
}
