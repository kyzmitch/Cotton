//
//  TabsViewController.swift
//  catowser
//
//  Created by admin on 18/06/2017.
//  Copyright © 2017 andreiermoshin. All rights reserved.
//

import UIKit
import CoreGraphics
import CoreBrowser

fileprivate extension TabsViewController {
    struct Sizes {
        static let tabsContainerHeight: CGFloat = .tabHeight
    }
}

/// The tabs controller for landscape mode (tablets)
final class TabsViewController: BaseViewController {
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
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var addTabButton: UIButton = {
        let addButton = UIButton()
        let image = UIImage(imageLiteralResourceName: "newTabButton-Normal")
        addButton.setImage(image, for: .normal)
        addButton.addTarget(self, action: #selector(addTabPressed), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        return addButton
    }()
    
    private lazy var showTabPreviewsButton: UIButton = {
        let showTabsButton = UIButton()
        showTabsButton.setTitleShadowColor(.black, for: .normal)
        showTabsButton.setTitleColor(.black, for: .normal)
        showTabsButton.setTitle("", for: .normal)
        showTabsButton.addTarget(self, action: #selector(showTabPreviewsPressed), for: .touchUpInside)
        showTabsButton.translatesAutoresizingMaskIntoConstraints = false
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
        
        stackViewScrollableContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackViewScrollableContainer.trailingAnchor.constraint(equalTo: addTabButton.leadingAnchor).isActive = true
        stackViewScrollableContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        stackViewScrollableContainer.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        
        tabsStackView.topAnchor.constraint(equalTo: stackViewScrollableContainer.topAnchor).isActive = true
        tabsStackView.bottomAnchor.constraint(equalTo: stackViewScrollableContainer.bottomAnchor).isActive = true
        tabsStackView.leadingAnchor.constraint(equalTo: stackViewScrollableContainer.leadingAnchor).isActive = true
        tabsStackView.trailingAnchor.constraint(equalTo: stackViewScrollableContainer.trailingAnchor).isActive = true
        
        addTabButton.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        addTabButton.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        addTabButton.leadingAnchor.constraint(equalTo: stackViewScrollableContainer.trailingAnchor).isActive = true
        addTabButton.widthAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        showTabPreviewsButton.leadingAnchor.constraint(equalTo: addTabButton.trailingAnchor).isActive = true
        showTabPreviewsButton.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        showTabPreviewsButton.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        showTabPreviewsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        showTabPreviewsButton.widthAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
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

    @objc func addTabPressed() {
        print("\(#function): add pressed")

        let tab = Tab(contentType: DefaultTabProvider.shared.contentState, selected: DefaultTabProvider.shared.selected)
        TabsListManager.shared.add(tab: tab)
    }

    // MARK: Action response handlers

    func add(_ tabView: TabView, at index: Int) {
        tabsStackView.insertArrangedSubview(tabView, at: index)
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
        let backLayer: CAGradientLayer = .lightBackgroundGradientLayer(bounds: bounds)
        tabsViewBackLayer = backLayer
        view.layer.insertSublayer(backLayer, at: 0)
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
            let size: CGSize = CGSize(width: 0, height: Sizes.tabsContainerHeight)

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
    func didSelect(index: Int, content: Tab.ContentType) {
        makeTabActive(at: index)
    }
    
    func update(with tabsCount: Int) {
        showTabPreviewsButton.setTitle("\(tabsCount)", for: .normal)
    }

    func initializeObserver(with tabs: [Tab]) {
        for (i, tab) in tabs.enumerated() {
            let tabView = TabView(frame: calculateNextTabFrame(), tab: tab, delegate: self)
            tabsStackView.insertArrangedSubview(tabView, at:i)
        }
        view.layoutIfNeeded()
    }
    
    func tabDidAdd(_ tab: Tab, at index: Int) {
        let tabView = TabView(frame: calculateNextTabFrame(), tab: tab, delegate: self)
        add(tabView, at: index)
    }

    func tabDidReplace(_ tab: Tab, at index: Int) {
        guard let view = tabsStackView.arrangedSubviews[safe: index], let tabView = view as? TabView else {
            print("Unknown tab view index \(index) count = \(tabsStackView.arrangedSubviews.count)")
            return
        }

        tabView.viewModel = tab
    }
}

extension TabsViewController: TabDelegate {
    func tabViewDidClose(_ tabView: TabView, was active: Bool) {
        print("\(#function): closed")
        removeTabView(tabView)
        if let site = tabView.viewModel.site {
            WebViewsReuseManager.shared.removeController(for: site)
        }
        TabsListManager.shared.close(tab: tabView.viewModel)
    }
    
    func tabDidBecomeActive(_ tab: Tab) {
        print("\(#function): tapped")
        TabsListManager.shared.select(tab: tab)
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
