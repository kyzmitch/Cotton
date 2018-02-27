//
//  BlankWebPageViewController.swift
//  catowser
//
//  Created by admin on 19/02/2018.
//  Copyright © 2018 andreiermoshin. All rights reserved.
//
// This class is for providing UI for bookmarks and
// last visited websites.
// Only one instance of that controller is needed
// because the view from this controller only
// displayed on tab without entered web site address.

import UIKit
import SnapKit

class BlankWebPageViewController: BaseViewController {
    
    // private lazy var mostVisitedWebSitesCollectionView: UICollectionView
    private var label: UILabel?
    
    override func loadView() {
        view = UIView()
        
        // TODO: remove temporary label
        // and replace it with collection view
        label = UILabel()
        label?.numberOfLines = 3
        label?.textAlignment = .center
        label!.text = "Page with most visited websites previews"
        label?.textColor = UIColor.black
        view.addSubview(label!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        label!.snp.makeConstraints { (make) in
            make.center.equalTo(view)
            make.width.equalTo(300)
            make.height.equalTo(100)
        }
    }
}
