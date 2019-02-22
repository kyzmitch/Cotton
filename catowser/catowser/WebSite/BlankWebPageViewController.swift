//
//  BlankWebPageViewController.swift
//  catowser
//
//  Created by admin on 19/02/2018.
//  Copyright © 2018 andreiermoshin. All rights reserved.
//

import UIKit
import SnapKit

final class BlankWebPageViewController: BaseViewController {
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        label.textAlignment = .center
        label.text = NSLocalizedString("msg_blank_site_message", comment: "To show that there is no site address")
        label.textColor = .black
        return label
    }()
    
    override func loadView() {
        view = UIView()

        view.addSubview(label)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white

        label.snp.makeConstraints { (make) in
            make.center.equalTo(view)
            let shift = 20
            make.leading.equalTo(shift)
            make.trailing.equalTo(-shift)
            make.height.equalTo(100)
        }
    }
}
