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
    /// keyboard is hidden and no text
    case clearTapped
    /// keyboard is hidden and old text
    case cancelTapped
    /// keyboard is visible
    case readyForInput
    /// when keyboard and all buttons are not displayed
    case viewMode
}

protocol SearchBarControllerInterface: class {
    func stateChanged(to state: SearchBarState)
    func setAddressString(_ address: String)
}

extension SearchBarControllerInterface {
    /* optional */ func stateChanged(to state: SearchBarState) {
    }
}

final class SearchBarBaseViewController: BaseViewController {

    /// The search bar view.
    private let searchBarView: UISearchBar = {
        let view = UISearchBar(frame: CGRect.zero)
        ThemeProvider.shared.setup(view)
        view.placeholder = NSLocalizedString("placeholder_searchbar", comment: "The text which is displayed when search bar is empty")
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

    private var siteAddress: String?

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
        // TODO: temporarily static content
        siteNameLabel.text = "opennet.ru"
        siteNameLabel.alpha = 0

        searchBarView.snp.makeConstraints { (maker) in
            maker.top.leading.trailing.bottom.equalTo(view)
        }

        siteNameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        siteNameLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        siteNameLabel.widthAnchor.constraint(equalTo: searchBarView.widthAnchor, constant: 0).isActive = true
        hiddenLabelConstraint.isActive = true
    }

    func rememberCurrentSiteAddress(_ address: String) {
        searchBarView.text = address
        siteAddress = address
    }

    func resetToRememberedSiteAddress() {
        searchBarView.text = siteAddress
    }

    func showCancelButton(_ show: Bool) {
        searchBarView.showsCancelButton = show
    }

    func prepareForViewMode() {
        searchBarView.setShowsCancelButton(false, animated: true)
        // Order of disabling/enabling is important to not to cause errors
        // in layout calculation
        // first need to disable and after that enable new one
        hiddenLabelConstraint.isActive = false
        showedLabelConstraint.isActive = true
        UIView.animate(withDuration: 0.3) {
            self.siteNameLabel.layoutIfNeeded()
            self.searchBarView.alpha = 0
            self.siteNameLabel.alpha = 1
        }
        searchBarView.resignFirstResponder()
    }
}

private extension SearchBarBaseViewController {
    @objc func handleSiteNameTap(_ gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer.view != nil else { return }
        
        guard gestureRecognizer.state == .ended else { return }
        showedLabelConstraint.isActive = false
        hiddenLabelConstraint.isActive = true
        searchBarView.becomeFirstResponder()

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
