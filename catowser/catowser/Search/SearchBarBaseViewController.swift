//
//  SearchBarBaseViewController.swift
//  catowser
//
//  Created by admin on 19/02/2018.
//  Copyright © 2018 andreiermoshin. All rights reserved.
//

import UIKit
import CoreBrowser

/// The sate of search bar
enum SearchBarState {
    /// keyboard and `cancel` button are visible
    case startSearch
    /// initial state for new blank tab
    case blankSearch
    /// keyboard is hidden and old text is visible
    case cancelTapped
    /// when keyboard and all buttons are not displayed
    case viewMode(title: String, searchAddressContent: String)
}

protocol SearchBarControllerInterface: class {
    /* non optional */ func changeState(to state: SearchBarState)
}

fileprivate extension String {
    static let placeholderText: String = NSLocalizedString("placeholder_searchbar", comment: "The text which is displayed when search bar is empty")
}

final class SearchBarBaseViewController: BaseViewController {

    /// The search bar view.
    private let searchBarView: UISearchBar = {
        let view = UISearchBar(frame: CGRect.zero)
        ThemeProvider.shared.setup(view)
        view.placeholder = .placeholderText
        return view
    }()

    private let siteNameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .black
        label.backgroundColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true

        return label
    }()

    /// To remember previously entered search query
    private var searchBarContent: String?

    private lazy var siteNameTapGesture: UITapGestureRecognizer = {
        // Need to init gesture lazily, if it will  be initialized as a constant
        // then it will not work :( action is not called.
        // Problem is with using `self` inside constant,
        // it seems it is not fully initialized at that point.
        // https://forums.swift.org/t/self-usage-inside-constant-property/21011
        // https://stackoverflow.com/questions/50393312/why-can-i-use-self-when-i-initialize-property-with-a-closure

        let tap = UITapGestureRecognizer(target: self, action: .siteNameTap)
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        return tap
    }()

    private lazy var hiddenLabelConstraint: NSLayoutConstraint = {
        return siteNameLabel.trailingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0)
    }()

    private lazy var showedLabelConstraint: NSLayoutConstraint = {
        return siteNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0)
    }()
    
    init(_ searchBarDelegate: UISearchBarDelegate) {
        super.init(nibName: nil, bundle: nil)
        
        searchBarView.delegate = searchBarDelegate
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        TabsListManager.shared.detach(self)
    }

    override func loadView() {
        view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(searchBarView)
        view.addSubview(siteNameLabel)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        siteNameLabel.addGestureRecognizer(siteNameTapGesture)
        siteNameLabel.alpha = 0

        searchBarView.snp.makeConstraints { (maker) in
            maker.top.leading.trailing.bottom.equalTo(view)
        }

        siteNameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        siteNameLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        siteNameLabel.widthAnchor.constraint(equalTo: searchBarView.widthAnchor, constant: 0).isActive = true
        hiddenLabelConstraint.isActive = true

        TabsListManager.shared.attach(self)
    }
}

extension SearchBarBaseViewController: TabsObserver {
    func tabDidReplace(_ tab: Tab, at index: Int) {
        // this also can be called on non active tab
        // but at the same time it really doesn't make sense
        // to replace site on tab which is not active
        // So, assume that `tab` parameter is currently selected
        // and will replace content which is currently disprlayed by search bar

        let state: SearchBarState = .viewMode(title: tab.title, searchAddressContent: tab.searchBarContent)
        changeState(to: state)
    }

    func didSelect(index: Int, content: Tab.ContentType) {
        let state: SearchBarState

        switch content {
        case .site(let site):
            state = .viewMode(title: site.title, searchAddressContent: site.searchBarContent)
        default:
            state = .blankSearch
        }

        changeState(to: state)
    }
}

extension SearchBarBaseViewController: SearchBarControllerInterface {
    func changeState(to state: SearchBarState) {
        switch state {
        case .startSearch:
            searchBarView.setShowsCancelButton(true, animated: true)
            guard searchBarView.text != nil else {
                break
            }
            // need somehow select all text in search bar view
            prepareForEditMode()
        case .blankSearch:
            searchBarView.text = nil
            siteNameLabel.text = .placeholderText
            searchBarView.setShowsCancelButton(false, animated: false)
            searchBarView.resignFirstResponder()
            // for blank mode it is better to hide label and
            // make search bar frontmost right away
            prepareForEditMode()
        case .cancelTapped:
            searchBarView.setShowsCancelButton(false, animated: true)
            searchBarView.resignFirstResponder()

            guard searchBarView.text != nil else {
                break
            }

            prepareForViewMode()
            // even if search bar now is not visible and
            // it is under label, need to revert text content in it
            searchBarView.text = self.searchBarContent
        case .viewMode(let title, let searchBarContent):
            searchBarView.setShowsCancelButton(false, animated: true)
            searchBarView.text = searchBarContent
            siteNameLabel.text = title
            prepareForViewMode()

            // remember search query in case if it will be edited
            self.searchBarContent = searchBarContent
        }
    }
}

private extension SearchBarBaseViewController {
    @objc func handleSiteNameTap(_ gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer.view != nil else { return }
        guard gestureRecognizer.state == .ended else { return }

        searchBarView.setShowsCancelButton(true, animated: true)
        searchBarView.becomeFirstResponder()
        prepareForEditMode()
    }

    func prepareForViewMode() {
        // Order of disabling/enabling is important to not to cause errors in layout calculation. First need to disable and after that enable new one.
        hiddenLabelConstraint.isActive = false
        showedLabelConstraint.isActive = true
        UIView.animate(withDuration: 0.3) {
            self.siteNameLabel.layoutIfNeeded()
            self.searchBarView.alpha = 0
            self.siteNameLabel.alpha = 1
        }
        searchBarView.resignFirstResponder()
    }

    func prepareForEditMode(and showKeyboard: Bool = false) {
        showedLabelConstraint.isActive = false
        hiddenLabelConstraint.isActive = true

        if showKeyboard {
            searchBarView.becomeFirstResponder()
        }

        UIView.animate(withDuration: 0.3) {
            self.siteNameLabel.layoutIfNeeded()
            self.siteNameLabel.alpha = 0
            self.searchBarView.alpha = 1
        }
    }
}

fileprivate extension Selector {
    static let siteNameTap = #selector(SearchBarBaseViewController.handleSiteNameTap(_:))
}
