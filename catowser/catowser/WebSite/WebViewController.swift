//
//  WebViewController.swift
//  catowser
//
//  Created by Andrey Ermoshin on 27/09/2017.
//  Copyright © 2017 andreiermoshin. All rights reserved.
//

import UIKit
import SnapKit
import WebKit

final class WebViewController: BaseViewController {
    
    var site: Site

    init(_ site: Site) {
        self.site = site
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let webView: WKWebView = {
        let webView = WKWebView()
        webView.backgroundColor = .black
        
        return webView
    }()
    
    override func loadView() {
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
        let request = URLRequest(url: site.url)
        webView.load(request)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // TODO: don't remember why it is needed
        if let touchedView = touches.first?.view {
            if touchedView === webView {
                webView.becomeFirstResponder()
            }
        }
    }
}

extension WebViewController: WKUIDelegate {

}

extension WebViewController: WKNavigationDelegate {
    
}
