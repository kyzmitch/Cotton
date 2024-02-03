//
//  LoadingProgressViewController.swift
//  catowser
//
//  Created by Andrei Ermoshin on 11/22/22.
//  Copyright © 2022 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import UIKit

final class LoadingProgressViewController: BaseViewController {
    /// The view required to demonstrait web content load process.
    private let webLoadProgressView: UIProgressView = {
        let v = UIProgressView(progressViewStyle: .default)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    override func loadView() {
        view = webLoadProgressView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
