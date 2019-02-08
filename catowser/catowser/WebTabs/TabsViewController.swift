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

// Is it only for tablets?
struct TabsViewModel {
    var tabsContainerHeight: CGFloat
    var topViewsOffset: CGFloat

    init(_ topOffset: CGFloat = UIConstants.topViewsOffset, _ heiht: CGFloat = UIConstants.tabHeight) {
        topViewsOffset = topOffset
        tabsContainerHeight = heiht
    }
}

/// The tabs controller for landscape mode (tablets)
final class TabsViewController: BaseViewController {
    
    var viewModel: TabsViewModel?
    
    private let tabsStackView: UIStackView = {
        // TODO: create a wrapper around UIStackView to provide
        // more convinient interface instead of direct usage for `arrangedSubviews`
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 6
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
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
    
    private lazy var showTabPreviewsButton: UIButton = {
        let showTabsButton = UIButton()
        showTabsButton.setTitleShadowColor(.black, for: .normal)
        showTabsButton.setTitleColor(.black, for: .normal)
        showTabsButton.setTitle("", for: .normal)
        showTabsButton.addTarget(self, action: #selector(showTabPreviewsPressed), for: .touchUpInside)
        return showTabsButton
    }()

    private var tabsViewBackLayer: CAGradientLayer?
    
    override func loadView() {
        view = UIView()
        
        view.addSubview(stackViewScrollableContainer)
        stackViewScrollableContainer.addSubview(tabsStackView)
        view.addSubview(addTabButton)
        view.addSubview(showTabPreviewsButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stackViewScrollableContainer.snp.makeConstraints { (maker) in
            maker.leading.equalTo(view).offset(0)
            maker.trailing.equalTo(addTabButton.snp.leading)
            maker.bottom.equalTo(view).offset(0)
            maker.top.equalTo(view).offset(0)
        }
        tabsStackView.snp.makeConstraints { (maker) in
            maker.top.equalTo(stackViewScrollableContainer)
            maker.bottom.equalTo(stackViewScrollableContainer)
            maker.leading.equalTo(stackViewScrollableContainer)
            maker.trailing.equalTo(stackViewScrollableContainer)
        }
        addTabButton.snp.makeConstraints { (maker) in
            maker.bottom.equalTo(view)
            maker.top.equalTo(view)
            maker.leading.equalTo(stackViewScrollableContainer.snp.trailing)
            maker.width.equalTo(view.snp.height)
        }
        showTabPreviewsButton.snp.makeConstraints { (maker) in
            maker.leading.equalTo(addTabButton.snp.trailing)
            maker.top.equalTo(0)
            maker.bottom.equalTo(0)
            maker.trailing.equalTo(view).offset(0)
            maker.width.equalTo(view.snp.height)
        }
        
        TabsListManager.shared.attach(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let tabs = TabsListManager.shared.fetch()
        for (i, tab) in tabs.enumerated() {
            let tabView = TabView(frame: calculateNextTabFrame(), tab: tab, delegate: self)
            add(tabView, at: i)
        }
        // TODO: handle selected index
    }
    
    deinit {
        TabsListManager.shared.detach(self)
    }
}

private extension TabsViewController {
    // MARK: IBActions

    @objc func showTabPreviewsPressed() {
        print("\(#function): show pressed")
        // Coordinator should be used here
        // to show tab previews collection view modally
    }

    @objc func addTabPressed() -> Void {
        print("\(#function): add pressed")

        let tab = Tab(contentType: DefaultTabProvider.shared.contentState, selected: DefaultTabProvider.shared.selected)
        TabsListManager.shared.add(tab: tab)
    }

    // MARK: Action response handlers

    func add(_ tabView: TabView, at index: Int) {
        tabsStackView.insertArrangedSubview(tabView, at:index)
        view.layoutIfNeeded()
        stackViewScrollableContainer.scrollToVeryRight()
    }

    func removeTabView(_ tabView: TabView) {
        tabsStackView.removeArrangedSubview(tabView)
        tabView.removeFromSuperview()
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        let count = tabsStackView.arrangedSubviews.count
        showTabPreviewsButton.setTitle("\(count)", for: .normal)
    }

    func selectNearbyTab(to tab: TabView) {
        if tabsStackView.arrangedSubviews.count == 1 {
            // next handling is just workaround which 99% of time will not be needed
            if let onlyOneView = tabsStackView.arrangedSubviews.first {
                if onlyOneView != tab {
                    (onlyOneView as? TabView)?.visualState = .selected
                }
            }
        } else {
            if let specifiedTabIndex = tabsStackView.arrangedSubviews.index(of: tab) {
                var nearTab: TabView?
                if specifiedTabIndex == 0 {
                    nearTab = tabsStackView.arrangedSubviews[1] as? TabView
                }
                else if specifiedTabIndex == tabsStackView.arrangedSubviews.count - 1 {
                    nearTab = tabsStackView.arrangedSubviews[specifiedTabIndex - 1] as? TabView
                }
                else {
                    // if in the middle then select previous from the left
                    nearTab = tabsStackView.arrangedSubviews[specifiedTabIndex - 1] as? TabView
                }

                if let searchedTab = nearTab {
                    searchedTab.visualState = .selected
                }
            }
            else {
                // Select something anyway
                print("\(#function): tab not found, will select some random one")
            }
        }
    }

    func makeTabFullyVisibleIfNeeded(_ tabView: TabView) {
        // the tab could be partly visible from the left, so
        // need to check if x coordinate of it not less than stackview x = 0
        // or it could be hidden by right side (+ button)
        // in that case need to check that x + width of tab is not bigger than
        // stackview width

        let containerWidth = stackViewScrollableContainer.bounds.size.width
        if stackViewScrollableContainer.contentSize.width <= containerWidth {
            return
        }

        let specificTabFrame = tabView.frame
        let realOrigin = stackViewScrollableContainer.convert(specificTabFrame.origin, from: tabsStackView)
        let tabVeryRigthX = realOrigin.x + specificTabFrame.size.width
        // TODO: finish impl below
        if specificTabFrame.origin.x < 0 {

        }
        else if tabVeryRigthX > containerWidth {

        }
        stackViewScrollableContainer.scroll(on: 100)
    }

    func makeTabActive(at index: Int) {
        for i in (0..<tabsStackView.arrangedSubviews.count) {
            guard let tabView = tabsStackView.arrangedSubviews[i] as? TabView else {
                assert(false, "unexpected view type")
                return
            }
            tabView.visualState = i == index ? .selected : .deselected
            if i == index {
                // if tab which was selected was partly hidden for example under + button
                // need to scroll it to make it fully visible
                makeTabFullyVisibleIfNeeded(tabView)
            }
        }
    }

    func updateTabsBackLayer(with width: CGFloat) {
        tabsViewBackLayer?.removeFromSuperlayer()
        var bounds = view.bounds
        bounds.size.width = width
        tabsViewBackLayer = CAGradientLayer.lightBackgroundGradientLayer(bounds: bounds)
        view.layer.insertSublayer(tabsViewBackLayer!, at: 0)
    }

    func resizeTabsWidthBasedOnCurrentHorizontalSizeClass() {
        for subview in tabsStackView.arrangedSubviews {
            subview.invalidateIntrinsicContentSize()
        }
    }

    func calculateNextTabFrame() -> CGRect {
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
        return newlyAddedTabFrame
    }
}

// MARK: Tabs observer
extension TabsViewController: TabsObserver {
    func didSelect(index: Int) {
        makeTabActive(at: index)
    }

    var name: String {
        return String(describing: self)
    }
    
    func update(with tabsCount: Int) {
        showTabPreviewsButton.setTitle("\(tabsCount)", for: .normal)
    }
    
    func tabDidAdd(_ tab: Tab, at index: Int) {
        let tabView = TabView(frame: calculateNextTabFrame(), tab: tab, delegate: self)
        add(tabView, at: index)
    }
}

extension TabsViewController: TabDelegate {
    func tab(_ tab: TabView, didPressCloseButton wasActive: Bool) {
        print("\(#function): closed")
        TabsListManager.shared.close(tab: tab.viewModel)
        if tab.visualState == .selected {
            // Need to activate some another tab in that case
            selectNearbyTab(to: tab)
        }
        removeTabView(tab)
    }
    
    func tab(_ tab: TabView, didBecomeActive active: Bool) {
        print("\(#function): tapped")
        guard active else {
            assert(active, "\(#function): not handled")
            return
        }
        TabsListManager.shared.select(tab: tab.viewModel)
    }
}

extension TabsViewController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // Need to redraw background layer
        updateTabsBackLayer(with: view.bounds.size.width)
        // change tabs width if needed
        resizeTabsWidthBasedOnCurrentHorizontalSizeClass()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        // https://stackoverflow.com/a/41805346/483101
        // Need to redraw background layer
        updateTabsBackLayer(with: size.width)
        // change tabs width if needed
        resizeTabsWidthBasedOnCurrentHorizontalSizeClass()
    }
}

extension CAGradientLayer {
    class func lightBackgroundGradientLayer(bounds: CGRect) -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
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
    
    func  scroll(on pixels: CGFloat) -> Void {
        // pixels could be negative to scroll to the left
        // TODO
    }
}
