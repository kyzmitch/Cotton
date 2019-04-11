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

enum SuggestionType {
    case suggestion(String)
    case knownDomain(String)
}

protocol SearchSuggestionsListDelegate: class {
    func didSelect(_ content: SuggestionType)
}

/// View controller to control suggestions view
/// Looks similar to one in Safari
final class SearchSuggestionsViewController: UITableViewController {

    var suggestions: [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    var knownDomains: [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    weak var delegate: SearchSuggestionsListDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        // https://www.hackingwithswift.com/example-code/uikit/how-to-register-a-cell-for-uitableviewcell-reuse
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: .searchSuggestionCellId)
    }

    fileprivate func value(from indexPath: IndexPath) -> String? {
        let text: String?
        switch indexPath.section {
        case 0:
            text = knownDomains[indexPath.row]
        case 1:
            text = suggestions[indexPath.row]
        default:
            text = nil
        }
        return text
    }
}

extension SearchSuggestionsViewController /* UITableViewDataSource */ {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return NSLocalizedString("ttl_search_history_domains", comment: "Known domains")
        case 1:
            return NSLocalizedString("ttl_search_suggestions", comment: "Suggestions from search engine")
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return knownDomains.count
        case 1:
            return suggestions.count
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: .searchSuggestionCellId, for: indexPath)
        cell.textLabel?.text = value(from: indexPath)
        return cell
    }
}

extension SearchSuggestionsViewController /* UITableViewDelegate */ {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let text = value(from: indexPath) else {
            return
        }

        let content: SuggestionType
        switch indexPath.section {
        case 0:
            content = .knownDomain(text)
        case 1:
            content = .suggestion(text)
        default:
            return
        }
        delegate?.didSelect(content)
    }
}
