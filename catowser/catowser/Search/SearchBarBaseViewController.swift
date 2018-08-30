//
//  SearchBarBaseViewController.swift
//  catowser
//
//  Created by admin on 19/02/2018.
//  Copyright © 2018 andreiermoshin. All rights reserved.
//

import UIKit

class SearchBarBaseViewController<SC: SearchClient>: BaseViewController, UISearchBarDelegate {

    private let searchBarView: UISearchBar
    private let suggestionsClient: SC
    
    init(_ searchSuggestionsClient: SC, _ searchBarDelegate: UISearchBarDelegate) {
        suggestionsClient = searchSuggestionsClient
        searchBarView = UISearchBar(frame: CGRect.zero)
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
