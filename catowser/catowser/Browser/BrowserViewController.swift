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
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.white
        
        let stackViewScrollableContainer = UIScrollView()
        stackViewScrollableContainer.backgroundColor = UIColor.cyan
        view.addSubview(stackViewScrollableContainer)
        stackViewScrollableContainer.snp.makeConstraints { (maker) in
            maker.height.equalTo(tabsContainerHeight)
            maker.topMargin.equalTo(view).offset(10)
            maker.leading.equalTo(view).offset(20)
            maker.trailing.equalTo(view).offset(-20)
        }
        
        stackViewScrollableContainer.addSubview(tabsStackView)
        tabsStackView.snp.makeConstraints { (maker) in
            maker.top.equalTo(0)
            maker.bottom.equalTo(0)
            maker.leading.equalTo(0)
            maker.trailing.equalTo(0)
            maker.height.equalToSuperview()
        }
        
        let tabRect = CGRect(origin: CGPoint.zero, size: CGSize(width: 0, height: 0))
        let tabView = TabView(frame: tabRect)
        tabView.modelView = TabViewModel(tabModel: TabModel(tabTitle: "First website"))
        tabsStackView.addArrangedSubview(tabView)
        
        let tabView2 = TabView(frame: tabRect)
        tabView2.modelView = TabViewModel(tabModel: TabModel(tabTitle: "Second website"))
        tabsStackView.addArrangedSubview(tabView2)
        
    }
}
