//
//  TabsPreviewsViewController.swift
//  catowser
//
//  Created by Andrei Ermoshin on 23/01/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import UIKit
import ReactiveSwift
import CoreBrowser

final class TabsPreviewsViewController: UIViewController, CollectionViewInterface {

    private var uxState: MutableProperty<State> = MutableProperty<State>(.loading)
    
    typealias TabsBox = Box<[Tab]>

    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
        cv.register(TabPreviewCell.self)
        cv.contentInset = UIEdgeInsets(top: 0 /* Sizes.searchBarHeight */, left: 0, bottom: 0, right: 0)
        cv.translatesAutoresizingMaskIntoConstraints = false

        return cv
    }()

    private let collectionLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        return layout
    }()

    private lazy var toolbar: UIToolbar = {
        // iOS 13.x fix for phone layout error
        // similar issue and fix:
        // https://github.com/hackiftekhar/IQKeyboardManager/pull/1598/files#diff-f73f23d86e3154de71cd5bd9abf275f0R146
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 1000, height: 44))
        ThemeProvider.shared.setup(toolbar)

        var barItems = [UIBarButtonItem]()
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        barItems.append(space)
        barItems.append(addTabButton)
        toolbar.setItems(barItems, animated: false)
        toolbar.translatesAutoresizingMaskIntoConstraints = false

        return toolbar
    }()

    private let addTabButton: UIBarButtonItem = {
        let img = UIImage(named: "newTabButton-Normal")
        let btn = UIBarButtonItem(image: img, style: .plain, target: self, action: .addTab)
        return btn
    }()

    private let spinnerView: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView(style: .whiteLarge)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private var disposables = [Disposable?]()

    private let router: TabsPreviewsRouter

    init(router: TabsPreviewsRouter) {
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self

        view.addSubview(collectionView)
        view.addSubview(toolbar)

        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: toolbar.topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true

        toolbar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        toolbar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

        disposables.append(uxState.signal
            .observe(on: UIScheduler())
            .observeValues { [weak self] state in
                self?.render(state: state)
        })

        render(state: uxState.value)
        TabsListManager.shared.attach(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let tabs = TabsListManager.shared.fetch()
        let tabsBox: TabsBox = TabsBox(tabs)
        uxState.value = .tabs(dataSource: tabsBox)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    deinit {
        TabsListManager.shared.detach(self)
        disposables.forEach {$0?.dispose()}
    }
}

fileprivate extension TabsPreviewsViewController {
    struct Sizes {
        static let margin = CGFloat(15)
    }
}

private extension TabsPreviewsViewController {
    func render(state: State) {
        switch state {
        case .loading: break

        case .tabs:
            break
        }

        collectionView.reloadData()
    }
}

extension TabsPreviewsViewController: TabsObserver {
    func tabDidAdd(_ tab: Tab, at index: Int) {
        guard case let .tabs(box) = uxState.value else {
            return
        }

        box.value.insert(tab, at: index)
        render(state: uxState.value)
    }

    func didSelect(index: Int, content: Tab.ContentType) {

    }
}

extension TabsPreviewsViewController: TabPreviewCellDelegate {
    func tabCellDidClose(at index: Int) {
        guard case let .tabs(box) = uxState.value else {
            return
        }

        let tab = box.value.remove(at: index)
        render(state: uxState.value)
        if let site = tab.site {
            WebViewsReuseManager.shared.removeController(for: site)
        }
        TabsListManager.shared.close(tab: tab)
    }
}

extension TabsPreviewsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Sizes.margin
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = floor((collectionView.bounds.width - Sizes.margin * CGFloat(numberOfColumns + 1)) / CGFloat(numberOfColumns))
        let cellHeight = TabPreviewCell.cellHeightForCurrent(traitCollection)
        return CGSize(width: cellWidth, height: cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(equalInset: Sizes.margin)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Sizes.margin
    }
}

extension TabsPreviewsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return uxState.value.itemsNumber
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var tab: Tab?
        switch uxState.value {
        case .tabs(let dataSource) where indexPath.item < dataSource.value.count:
            // must use `item` for UICollectionView
            tab = dataSource.value[safe: indexPath.item]
        default: break
        }

        guard let correctTab = tab else {
            print("\(#function) wrong index")
            return UICollectionViewCell(frame: .zero)
        }
        let cell = collectionView.dequeueCell(at: indexPath, type: TabPreviewCell.self)
        cell.configure(with: correctTab, at: indexPath.item, delegate: self)
        return cell
    }
}

extension TabsPreviewsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let tab = TabsListManager.shared.selectTab(at: indexPath) else {
            return
        }
        router.dismiss(andLoad: tab.contentType)
    }
}

private extension TabsPreviewsViewController {
    @objc func clearTabsPressed() {

    }

    @objc func addTabPressed() {
        // on previews screen will make new added tab always selected
        // same behaviour has Safari and Firefox
        let select = DefaultTabProvider.shared.selected
        let tab = Tab(contentType: DefaultTabProvider.shared.contentState, selected: select)
        // newly added tab moves selection to itself
        // so, it is opened by manager by default
        // but user maybe don't want to move that tab right away
        TabsListManager.shared.add(tab: tab)
        if select {
            router.dismiss(andLoad: tab.contentType)
        }
    }
}

fileprivate extension Selector {
    static let clearTabs = #selector(TabsPreviewsViewController.clearTabsPressed)
    static let addTab = #selector(TabsPreviewsViewController.addTabPressed)
}

fileprivate extension TabsPreviewsViewController {
    enum State {
        /// Maybe it is not needed state, but it is required for scalability when some user will have 100 tabs
        case loading
        /// Actual collection for tabs, at least one tab always will be in it
        case tabs(dataSource: TabsBox)

        var itemsNumber: Int {
            switch self {
            case .loading:
                return 0
            case .tabs(let box):
                return box.value.count
            }
        }
    }
}
