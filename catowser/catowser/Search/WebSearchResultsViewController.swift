//
//  WebSearchResultsViewController.swift
//  catowser
//
//  Created by Andrey Ermoshin on 22/02/2018.
//  Copyright © 2018 andreiermoshin. All rights reserved.
//

import UIKit

protocol WebPageDescription {
    var webAddress: URL {get set}
    var title: String {get set}
    var shortDescription: String {get set}
    var icon: UIImage {get set}
}

protocol WebSearchResult {
    var searchEngineName: String {get set}
    var numberOfSearchResults: Int {get set}
    func searchResultDescription(for number: Int) -> WebPageDescription
}

protocol TextWebSearchResult: WebSearchResult {
    var searchedText: String {get set}
}

extension TextWebSearchResult {
    func searchedKeywords() -> [String] {
        return searchedText.split(separator: " ").filter {$0.count >= 3}.map {String($0)}
    }
}

protocol ImageWebSearchResult: WebSearchResult {
    var searchedImage: UIImage {get set}
}

class WebSearchResultsViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    private enum DataSourceState {
        case empty
        case found(String, TextWebSearchResult)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(webSitesTable)
        webSitesTable.snp.makeConstraints { (make) in
            make.leading.equalTo(view)
            make.trailing.equalTo(view)
            make.top.equalTo(view)
            make.bottom.equalTo(view)
        }
        
        webSitesTable.register(WebSearchResultTableViewCell.layerClass, forCellReuseIdentifier: WebSearchResultTableViewCell.cellIdentifier)
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
        if case let .found(_, searchResult) = dataState {
            return searchResult.numberOfSearchResults
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WebSearchResultTableViewCell.cellIdentifier, for: indexPath) as! WebSearchResultTableViewCell
        if case let .found(_, searchResult) = dataState {
            cell.configure(using: searchResult.searchResultDescription(for: indexPath.row))
        }
        return cell
    }
}
