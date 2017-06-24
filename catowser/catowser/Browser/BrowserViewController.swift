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
    
    public var viewModel: BrowserViewModel? {
        willSet {
            if let vm = newValue {
                stackViewScrollableContainer.snp.makeConstraints { (maker) in
                    maker.height.equalTo(vm.tabsContainerHeight)
                    maker.topMargin.equalTo(view).offset(10)
                    maker.leading.equalTo(view).offset(0)
                    maker.trailing.equalTo(view).offset(0)
                }
            }
        }
    }
    
    private let tabsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.axis = .horizontal
        return stackView
    }()
    
    private let stackViewScrollableContainer: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.white
        
        view.addSubview(stackViewScrollableContainer)
        stackViewScrollableContainer.snp.makeConstraints { (maker) in
            maker.height.equalTo(40.0)
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
        
        // Code for debug to check tabs look and scrolling
        let tabRect = CGRect(origin: CGPoint.zero, size: CGSize.zero)
        for i in 0..<10 {
            let tabView = TabView(frame: tabRect)
            let title = "Home \(i)"
            tabView.modelView = TabViewModel(tabModel: TabModel(tabTitle: title))
            tabsStackView.addArrangedSubview(tabView)
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        
        let bounds = stackViewScrollableContainer.bounds
        stackViewScrollableContainer.layer.insertSublayer(CAGradientLayer.lightBackgroundGradientLayer(bounds: bounds), at: 0)
    }
}

extension CAGradientLayer {
    class func lightBackgroundGradientLayer(bounds: CGRect) -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.frame = bounds
        let topColor: CGColor = UIColor.white.cgColor
        let bottomColor: CGColor = UIColor.gray.cgColor
        layer.colors = [topColor, bottomColor]
        layer.locations = [0.0, 1.0]
        return layer
    }
}
