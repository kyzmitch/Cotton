//
//  WebSearchResultsViewController.swift
//  catowser
//
//  Created by Andrey Ermoshin on 22/02/2018.
//  Copyright © 2018 andreiermoshin. All rights reserved.
//

import UIKit

final class WebSearchResultsViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    private enum DataSourceState {
        case empty
        case found(String)
    }
    
    // Only one search engine at the moment
    // for example Google
    private var dataState: DataSourceState = .empty
    
    private lazy var webSitesTable: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    override func loadView() {
        view = UIView()
        
        view.addSubview(webSitesTable)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webSitesTable.snp.makeConstraints { (make) in
            make.leading.equalTo(view)
            make.trailing.equalTo(view)
            make.top.equalTo(view)
            make.bottom.equalTo(view)
        }

        webSitesTable.register(WebSearchResultTableViewCell.self, forCellReuseIdentifier: WebSearchResultTableViewCell.cellIdentifier)
    }

    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if case .found = dataState {
            return 1
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WebSearchResultTableViewCell.cellIdentifier, for: indexPath) as! WebSearchResultTableViewCell
        return cell
    }
}
