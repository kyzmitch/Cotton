//
//  SearchSuggestionsViewController.swift
//  catowser
//
//  Created by Andrey Ermoshin on 22/02/2018.
//  Copyright © 2018 andreiermoshin. All rights reserved.
//

import UIKit

fileprivate extension String {
    static let searchSuggestionCellId = "SearchSuggestionCellId"
}

/// View controller to control suggestions view
/// Looks similar to one in Safari
final class SearchSuggestionsViewController: UITableViewController {

    var suggestions: [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // https://www.hackingwithswift.com/example-code/uikit/how-to-register-a-cell-for-uitableviewcell-reuse
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: .searchSuggestionCellId)
    }
}

extension SearchSuggestionsViewController /* UITableViewDataSource */ {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Currently will be designed to support only one source
        // e.g. search suggestions from DuckDuckGo
        // but in the future it could be better to add different sources
        // as additional sections
        return suggestions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: .searchSuggestionCellId, for: indexPath)
        cell.textLabel?.text = suggestions[indexPath.row]
        return cell
    }
}
