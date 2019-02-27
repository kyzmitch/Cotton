//
//  SearchBarBaseViewController.swift
//  catowser
//
//  Created by admin on 19/02/2018.
//  Copyright © 2018 andreiermoshin. All rights reserved.
//

import UIKit

/// The sate of search bar
enum SearchBarState {
    /// keyboard and `cancel` button are visible
    case startSearch
    /// initial state for new blank tab
    case blankSearch
    /// keyboard is hidden and old text is visible
    case cancelTapped
    /// when keyboard and all buttons are not displayed
    case viewMode(suggestion: String?, host: String)
}

protocol SearchBarControllerInterface: class {
    func changeState(to state: SearchBarState)
}

extension SearchBarControllerInterface {
    /* optional */ func changeState(to state: SearchBarState) {
    }
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

    private lazy var siteNameTapGesture: UITapGestureRecognizer = {
        // Need to init gesture lazily, if it will  be initialized as a constant
        // then it will not work :( action is not called
        let tap = UITapGestureRecognizer(target: self, action: .siteNameTap)
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        return tap
    }()

    /// Should store search query or web site domain if website is not a search engine. Can be empty if active tab is blank.
    /// Later need to think if real URL will be needed, to store it in different property.
    private var searchContent: String? {
        didSet {
            searchBarView.text = searchContent
            // if search queue is empty then need to show placeholder
            siteNameLabel.text = searchContent ?? .placeholderText
        }
    }

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
    }
}

extension SearchBarBaseViewController: SearchBarControllerInterface {
    func changeState(to state: SearchBarState) {
        switch state {
        case .startSearch:
            searchBarView.setShowsCancelButton(true, animated: true)
            guard searchContent != nil else {
                break
            }
            // need somehow select all text in search bar view
            prepareForEditMode()
            // also probably need to set current text for search bar
        case .blankSearch:
            searchContent = nil
            searchBarView.setShowsCancelButton(false, animated: false)
            searchBarView.resignFirstResponder()
            // for blank mode it is better to hide label and
            // make search bar frontmost right away
            prepareForEditMode()
        case .cancelTapped:
            searchBarView.setShowsCancelButton(false, animated: true)
            searchBarView.resignFirstResponder()

            guard searchContent != nil else {
                break
            }

            prepareForViewMode()
            // even if search bar now is not visible and
            // it is under label, need to revert text content in it
            searchBarView.text = searchContent
        case .viewMode(let suggestionString, let hostString):
            searchBarView.setShowsCancelButton(false, animated: true)
            searchContent = suggestionString ?? hostString
            prepareForViewMode()
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
