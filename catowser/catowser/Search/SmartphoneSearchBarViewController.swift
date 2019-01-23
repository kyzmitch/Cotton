//
//  SmartphoneSearchBarViewController.swift
//  catowser
//
//  Created by admin on 19/02/2018.
//  Copyright © 2018 andreiermoshin. All rights reserved.
//

import UIKit

final class SmartphoneSearchBarViewController: BaseViewController {

    let searchBarViewController: SearchBarBaseViewController<SearchSuggestClient<AlamofireHttpClient>>

    private let goBackButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = ThemeProvider.shared.theme.searchBarButtonBackgroundColor
        let img = UIImage(named: "goBack")
        btn.setImage(img, for: .normal)

        return btn
    }()

    private lazy var backButtonNormalWidth: NSLayoutConstraint = {
        return goBackButton.widthAnchor.constraint(equalTo: view.heightAnchor)
    }()

    private lazy var backButtonZeroWidth: NSLayoutConstraint = {
        return goBackButton.widthAnchor.constraint(equalToConstant: 0.0)
    }()

    init(_ searchSuggestionsClient: SearchSuggestClient<AlamofireHttpClient>, _ searchBarDelegate: UISearchBarDelegate) {
        searchBarViewController = SearchBarBaseViewController(searchSuggestionsClient, searchBarDelegate)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(goBackButton)
        add(asChildViewController: searchBarViewController, to:view)
        
        goBackButton.translatesAutoresizingMaskIntoConstraints = false
        searchBarViewController.view.translatesAutoresizingMaskIntoConstraints = false

        goBackButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        goBackButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        goBackButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        backButtonNormalWidth.isActive = true

        searchBarViewController.view.leadingAnchor.constraint(equalTo: goBackButton.trailingAnchor, constant: 0).isActive = true
        searchBarViewController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        searchBarViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        searchBarViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
    }
}

extension SmartphoneSearchBarViewController: SearchBarControllerInterface {
    func stateChanged(to state: SearchBarState) {
        switch state {
        case .readyForInput:
            backButtonNormalWidth.isActive = false
            backButtonZeroWidth.isActive = true
            searchBarViewController.searchBarView.setShowsCancelButton(true, animated: true)
        case .clear:
            // You always want to first deactivate the old one and then activate
            // the new one, otherwise for that moment when you activate the new
            // one it would conflict with the old one and cause warnings in console.
            backButtonZeroWidth.isActive = false
            backButtonNormalWidth.isActive = true
            searchBarViewController.searchBarView.setShowsCancelButton(false, animated: false)
        }
    }

    func isBlank() -> Bool {
        return true
    }
}
