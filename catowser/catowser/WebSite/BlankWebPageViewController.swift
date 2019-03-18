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
    private let logo: UIImageView = {
        let img = UIImage(named: "Logo")
        let imgView = UIImageView(image: img)
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    override func loadView() {
        view = UIView()

        view.addSubview(logo)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white

        logo.snp.makeConstraints { (make) in
            make.center.equalTo(view)
            make.width.height.equalTo(120)
        }
    }
}
