//
//  TabsViewController.swift
//  catowser
//
//  Created by admin on 18/06/2017.
//  Copyright © 2017 andreiermoshin. All rights reserved.
//

import UIKit
import CoreGraphics
import SnapKit

class TabsViewController: BaseViewController {
    
    public var viewModel: TabsViewModel?
    
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
    
    @objc private func addTabPressed() -> Void {
        print("\(#function): add pressed")
        
        // Need to find out the very right tab view coordinates
        // to know initial coordinates for newly added tab view
        // to make animation of adding new tab view more smooth
        var newlyAddedTabFrame: CGRect
        if let veryRightTabView = tabsStackView.arrangedSubviews.last {
            let origin = CGPoint(x: veryRightTabView.frame.origin.x + veryRightTabView.frame.size.width, y: 0)
            var size: CGSize
            if let tabHeight = viewModel?.tabsContainerHeight {
                size = CGSize(width: 0, height: tabHeight)
            }
            else {
                size = CGSize(width: 0, height: UIConstants.tabHeight)
            }
            
            newlyAddedTabFrame = CGRect(origin: origin, size: size)
        }
        else {
            newlyAddedTabFrame = CGRect.zero
        }
        
        let tabView = TabView(frame: newlyAddedTabFrame)
        tabView.delegate = self
        tabView.modelView = TabViewModel(tabModel: TabModel())
        addTabView(tabView)
    }
    
    private func addTabView(_ tabView: TabView) {
        let count = tabsStackView.arrangedSubviews.count
        tabsStackView.insertArrangedSubview(tabView, at:count)
        if count == 0 {
            makeTabActive(tabView)
        }
        self.view.layoutIfNeeded()
        stackViewScrollableContainer.scrollToVeryRight()
    }
    
    private func removeTabView(_ tabView: TabView) {
        tabsStackView.removeArrangedSubview(tabView)
        tabView.removeFromSuperview()
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func makeTabActive(_ tabView: TabView) {
        for stackSubView in tabsStackView.arrangedSubviews {
            if let specificTab = stackSubView as? TabView {
                specificTab.visualState = (specificTab !== tabView) ? TabVisualState.deselected : TabVisualState.selected
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var tabsHeight: CGFloat
        if let vm = viewModel {
            tabsHeight = vm.tabsContainerHeight
        }
        else {
            tabsHeight = UIConstants.tabHeight
        }
        
        view.addSubview(addTabButton)
        addTabButton.snp.makeConstraints { (maker) in
            maker.bottom.equalTo(view.snp.bottom)
            maker.width.equalTo(tabsHeight)
            maker.height.equalTo(tabsHeight)
            maker.trailing.equalTo(view.snp.trailing)
        }
        
        view.addSubview(stackViewScrollableContainer)
        stackViewScrollableContainer.snp.makeConstraints { (maker) in
            maker.leading.equalTo(view).offset(0)
            maker.trailing.equalTo(addTabButton.snp.leading)
            maker.bottom.equalTo(view).offset(0)
            maker.height.equalTo(tabsHeight)
        }
        
        stackViewScrollableContainer.addSubview(tabsStackView)
        tabsStackView.snp.makeConstraints { (maker) in
            maker.top.equalTo(stackViewScrollableContainer)
            maker.bottom.equalTo(stackViewScrollableContainer)
            maker.leading.equalTo(stackViewScrollableContainer)
            maker.trailing.equalTo(stackViewScrollableContainer)
        }
    }
    
    private var tabsViewBackLayer: CAGradientLayer?
    
    private func resizeTabsBackLayer() -> Void {
        tabsViewBackLayer?.removeFromSuperlayer()
        let frame = view.frame
        tabsViewBackLayer = CAGradientLayer.lightBackgroundGradientLayer(frame: frame)
        view.layer.insertSublayer(tabsViewBackLayer!, at: 0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("\(#function): new layout")
        resizeTabsBackLayer()
    }
}

extension TabsViewController: TabDelegate {
    func tab(_ tab: TabView, didPressCloseButton wasActive: Bool) {
        print("\(#function): closed")
        removeTabView(tab)
    }
    
    func tab(_ tab: TabView, didBecomeActive active: Bool) {
        print("\(#function): tapped")
        makeTabActive(tab)
    }
}

extension TabsViewController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        print("\(#function): device was rotated")
        // Need to redraw background layer
        resizeTabsBackLayer()
        
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

extension UIScrollView {
    func scrollToVeryRight() -> Void {
        if self.contentSize.width <= self.bounds.size.width {
            return
        }
        let bottomOffset = CGPoint(x: self.contentSize.width - self.bounds.size.width, y: 0)
        self.setContentOffset(bottomOffset, animated: true)
    }
}
