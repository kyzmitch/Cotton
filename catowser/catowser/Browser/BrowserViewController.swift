//
//  BrowserViewController.swift
//  catowser
//
//  Created by admin on 18/06/2017.
//  Copyright © 2017 andreiermoshin. All rights reserved.
//

import UIKit
import CoreGraphics
import SnapKit

class BrowserViewController: UIViewController {
    
    private let tabsContainerHeight = 40.0
    public var viewModel: BrowserViewModel?
    
    private let tabsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.axis = .horizontal
        stackView.backgroundColor = UIColor.orange
        return stackView
    }()
    
    private let stackViewScrollableContainer: UIScrollView = {
        let stackView = UIScrollView()
        stackView.showsHorizontalScrollIndicator = false
        stackView.backgroundColor = UIColor.cyan
        return stackView
    }()
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.white
        
        view.addSubview(stackViewScrollableContainer)
        stackViewScrollableContainer.snp.makeConstraints { (maker) in
            maker.height.equalTo(tabsContainerHeight)
            maker.topMargin.equalTo(view).offset(10)
            maker.leading.equalTo(view).offset(0)
            maker.trailing.equalTo(view).offset(0)
        }
        
        stackViewScrollableContainer.addSubview(tabsStackView)
        tabsStackView.snp.makeConstraints { (maker) in
            maker.top.equalTo(0)
            maker.bottom.equalTo(0)
            maker.leading.equalTo(0)
            maker.trailing.equalTo(0)
            maker.height.equalToSuperview()
        }
        
        let tabRect = CGRect(origin: CGPoint.zero, size: CGSize.zero)
        for i in 0..<10 {
            let tabView = TabView(frame: tabRect)
            let title = "Home \(i)"
            tabView.modelView = TabViewModel(tabModel: TabModel(tabTitle: title))
            tabsStackView.addArrangedSubview(tabView)
        }
        
    }
}
