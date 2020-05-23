//
//  SmartphoneSearchBarViewController.swift
//  catowser
//
//  Created by admin on 19/02/2018.
//  Copyright © 2018 andreiermoshin. All rights reserved.
//

import UIKit
import CoreBrowser

final class SmartphoneSearchBarViewController: BaseViewController {

    let searchBarViewController: SearchBarBaseViewController

    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeProvider.shared.theme.searchBarSeparatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    init(_ searchBarDelegate: UISearchBarDelegate) {
        searchBarViewController = SearchBarBaseViewController(searchBarDelegate)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        add(asChildViewController: searchBarViewController, to: view)
        view.addSubview(lineView)

        searchBarViewController.view.translatesAutoresizingMaskIntoConstraints = false

        searchBarViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        searchBarViewController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        searchBarViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        searchBarViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                               constant: 0).isActive = true

        lineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        lineView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        lineView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        lineView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
    }
}

extension SmartphoneSearchBarViewController: AnyViewController {}

extension SmartphoneSearchBarViewController: SearchBarControllerInterface {
    func changeState(to state: SearchBarState, animated: Bool) {
        searchBarViewController.changeState(to: state, animated: animated)
    }
}
