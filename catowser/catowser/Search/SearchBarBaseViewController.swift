//
//  SearchBarBaseViewController.swift
//  catowser
//
//  Created by admin on 19/02/2018.
//  Copyright © 2018 andreiermoshin. All rights reserved.
//

import UIKit

final class SearchBarBaseViewController: BaseViewController {

    /// The search bar view. Must be public to allow control `cancel` button.
    /// Later it can be better to make it private and create function.
    let searchBarView: UISearchBar = {
        let view = UISearchBar(frame: CGRect.zero)
        ThemeProvider.shared.setup(view)
        view.placeholder = NSLocalizedString("placeholder_searchbar", comment: "The text which is displayed when search bar is empty")
        return view
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
}
