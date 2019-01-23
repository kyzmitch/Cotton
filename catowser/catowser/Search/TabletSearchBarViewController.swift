//
//  TabletSearchBarViewController.swift
//  catowser
//
//  Created by admin on 19/02/2018.
//  Copyright © 2018 andreiermoshin. All rights reserved.
//

import UIKit

final class TabletSearchBarViewController: BaseViewController {

    let searchBarViewController: SearchBarBaseViewController<SearchSuggestClient<AlamofireHttpClient>>
    
    init(_ searchSuggestionsClient: SearchSuggestClient<AlamofireHttpClient>, _ searchBarDelegate: UISearchBarDelegate) {
        searchBarViewController = SearchBarBaseViewController(searchSuggestionsClient, searchBarDelegate)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let goBackButton: UIButton = {
        let btn = UIButton()
        let img = UIImage(named: "nav-back")
        btn.backgroundColor = ThemeProvider.shared.theme.searchBarButtonBackgroundColor
        btn.setImage(img, for: .normal)
        return btn
    }()
    
    private let goForwardButton: UIButton = {
        let btn = UIButton()
        let img = UIImage(named: "nav-forward")
        btn.backgroundColor = ThemeProvider.shared.theme.searchBarButtonBackgroundColor
        btn.setImage(img, for: .normal)
        return btn
    }()
    
    private let reloadButton: UIButton = {
        let btn = UIButton()
        let img = UIImage(named: "nav-refresh")
        btn.backgroundColor = ThemeProvider.shared.theme.searchBarButtonBackgroundColor
        btn.setImage(img, for: .normal)
        return btn
    }()
    
    // "nav-menu" image from assets should be used for settings button
    
    override func loadView() {
        view = UIView()
        
        view.addSubview(goBackButton)
        view.addSubview(goForwardButton)
        view.addSubview(reloadButton)
        add(asChildViewController: searchBarViewController, to:view)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIConstants.searchBarBackgroundColour
        
        goBackButton.snp.makeConstraints { (maker) in
            maker.leading.equalTo(0)
            maker.top.equalTo(0)
            maker.bottom.equalTo(0)
            maker.width.equalTo(view.snp.height)
        }
        goForwardButton.snp.makeConstraints { (maker) in
            maker.leading.equalTo(goBackButton.snp.trailing)
            maker.top.equalTo(0)
            maker.bottom.equalTo(0)
            maker.width.equalTo(view.snp.height)
        }
        reloadButton.snp.makeConstraints { (maker) in
            maker.leading.equalTo(goForwardButton.snp.trailing)
            maker.top.equalTo(0)
            maker.bottom.equalTo(0)
            maker.width.equalTo(view.snp.height)
        }
        searchBarViewController.view.snp.makeConstraints { (maker) in
            maker.leading.equalTo(reloadButton.snp.trailing)
            maker.top.equalTo(0)
            maker.bottom.equalTo(0)
            maker.trailing.equalTo(0)
        }
    }
}

extension TabletSearchBarViewController: SearchBarControllerInterface {
    func stateChanged(to state: SearchBarState) {
        
    }

    func isBlank() -> Bool {
        return true
    }
}
