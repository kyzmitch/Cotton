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

class BrowserViewController: BaseViewController {
    
    public var viewModel: BrowserViewModel? {
        willSet {
            if let vm = newValue {
                stackViewScrollableContainer.snp.makeConstraints { (maker) in
                    maker.height.equalTo(vm.tabsContainerHeight)
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
        scrollView.bounces = false
        return scrollView
    }()
    
    private let addTabButton: UIButton = {
        let addButton = UIButton()
        let image = UIImage(imageLiteralResourceName: "newTabButton-Normal")
        addButton.setImage(image, for: .normal)
        addButton.addTarget(self, action: #selector(addTabPressed), for: .touchUpInside)
        return addButton
    }()
    
    private let webContentBackgroundView: UIView = {
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(colorLiteralRed: 192/255.0, green: 240/255.0, blue: 144/255.0, alpha: 1.0)
        return backgroundView
    }()
    
    @objc private func addTabPressed() -> Void {
        print("\(#function): add pressed")
        
        let tabView = TabView(frame: CGRect.zero)
        tabView.delegate = self
        let title = "Blank"
        tabView.modelView = TabViewModel(tabModel: TabModel(tabTitle: title))
        addTabView(tabView)
    }
    
    private func addTabView(_ tabView: TabView) {
        let count = tabsStackView.arrangedSubviews.count
        tabsStackView.insertArrangedSubview(tabView, at:count)
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func removeTabView(_ tabView: TabView) {
        tabsStackView.removeArrangedSubview(tabView)
        tabView.removeFromSuperview()
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    private let topViewsOffset = CGFloat(10)
    private let topViewPanelHeight = CGFloat(40)
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.white
        
        view.addSubview(addTabButton)
        addTabButton.snp.makeConstraints { (maker) in
            maker.topMargin.equalTo(view).offset(topViewsOffset)
            maker.height.equalTo(topViewPanelHeight)
            maker.width.equalTo(topViewPanelHeight)
            maker.trailing.equalTo(view).offset(0)
        }
        
        view.addSubview(stackViewScrollableContainer)
        stackViewScrollableContainer.snp.makeConstraints { (maker) in
            maker.height.equalTo(topViewPanelHeight)
            maker.topMargin.equalTo(view).offset(topViewsOffset)
            maker.leading.equalTo(view).offset(0)
            maker.trailing.equalTo(addTabButton.snp.leading)
        }
        
        view.addSubview(webContentBackgroundView)
        webContentBackgroundView.snp.makeConstraints { (maker) in
            maker.top.equalTo(stackViewScrollableContainer.snp.bottom)
            maker.leading.equalTo(view).offset(0)
            maker.trailing.equalTo(view).offset(0)
            maker.bottom.equalTo(view).offset(0)
        }
        
        stackViewScrollableContainer.addSubview(tabsStackView)
        tabsStackView.snp.makeConstraints { (maker) in
            maker.top.equalTo(0)
            maker.bottom.equalTo(0)
            maker.leading.equalTo(0)
            maker.trailing.equalTo(0)
            maker.height.equalToSuperview()
        }
    }
    
    private var tabsViewBackLayer: CAGradientLayer?
    
    private func resizeTabsBackLayer() -> Void {
        tabsViewBackLayer?.removeFromSuperlayer()
        let frame = stackViewScrollableContainer.frame
        tabsViewBackLayer = CAGradientLayer.lightBackgroundGradientLayer(frame: frame)
        view.layer.insertSublayer(tabsViewBackLayer!, at: 0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        resizeTabsBackLayer()
    }
}

extension BrowserViewController: TabDelegate {
    func tab(_ tab: TabView, didPressCloseButton wasActive: Bool) {
        print("\(#function): closed")
        removeTabView(tab)
    }
}

extension CAGradientLayer {
    class func lightBackgroundGradientLayer(frame: CGRect) -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: frame.size.height)
        let topColor: CGColor = UIColor.white.cgColor
        let bottomColor: CGColor = UIColor.lightGray.cgColor
        layer.colors = [topColor, bottomColor]
        layer.locations = [0.0, 1.0]
        return layer
    }
}
