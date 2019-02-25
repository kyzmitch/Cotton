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

    private var siteAddress: String?
    
    init(_ searchBarDelegate: UISearchBarDelegate) {
        super.init(nibName: nil, bundle: nil)
        
        searchBarView.delegate = searchBarDelegate
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView()

        view.addSubview(searchBarView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBarView.snp.makeConstraints { (maker) in
            maker.top.equalTo(0)
            maker.leading.equalTo(0)
            maker.trailing.equalTo(0)
            maker.bottom.equalTo(0)
        }
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
}
