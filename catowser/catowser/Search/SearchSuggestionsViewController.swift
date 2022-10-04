//
//  SearchSuggestionsViewController.swift
//  catowser
//
//  Created by Andrey Ermoshin on 22/02/2018.
//  Copyright © 2018 andreiermoshin. All rights reserved.
//

import UIKit
import FeaturesFlagsKit
import ReactiveSwift
import Combine
import CoreCatowser

fileprivate extension String {
    static let searchSuggestionCellId = "SearchSuggestionCellId"
}

enum SuggestionType {
    case suggestion(String)
    case knownDomain(String)
    case looksLikeURL(String)
}

protocol SearchSuggestionsListDelegate: AnyObject {
    func didSelect(_ content: SuggestionType)
}

/// View controller to control suggestions view
/// Looks similar to one in Safari
final class SearchSuggestionsViewController: UITableViewController {
    private let viewModel: SearchSuggestionsViewModel
    
    private var state: SearchSuggestionsViewState = .waitingForQuery {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var disposable: Disposable?
    
    private var cancellable: AnyCancellable?
    
    /// Combine cancellable for Concurrency Published property
    private var taskHandler: AnyCancellable?
    
    weak var delegate: SearchSuggestionsListDelegate?

    init() {
        viewModel = ViewModelFactory.shared.searchSuggestionsViewModel()
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        cancellable?.cancel()
        disposable?.dispose()
        taskHandler?.cancel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        // https://www.hackingwithswift.com/example-code/uikit/how-to-register-a-cell-for-uitableviewcell-reuse
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: .searchSuggestionCellId)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switch FeatureManager.appAsyncApiTypeValue() {
        case .reactive:
            disposable?.dispose()
            disposable = viewModel.rxState.signal.producer.startWithValues(onStateChange)
        case .combine:
            cancellable?.cancel()
            cancellable = viewModel.combineState.sink(receiveValue: onStateChange)
        case .asyncAwait:
            taskHandler?.cancel()
            taskHandler = viewModel.statePublisher.sink(receiveValue: onStateChange)
        }
        
        // Also would be good to obverve for changes in settings
        // to notify user to close and open this search table
        // to re-create view model with recently selected auto complete source.
        // Need to update FeatureManager enum features
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        disposable?.dispose()
        cancellable?.cancel()
        taskHandler?.cancel()
    }

    func prepareSearch(for searchText: String) {
        viewModel.fetchSuggestions(searchText)
    }
    
    private func onStateChange(_ state: SearchSuggestionsViewState) {
        guard self.state != state else {
            return
        }
        self.state = state
    }
}

extension SearchSuggestionsViewController /* UITableViewDataSource */ {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return state.sectionsNumber
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
        return state.rowsCount(section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: .searchSuggestionCellId, for: indexPath)
        cell.textLabel?.text = state.value(from: indexPath)
        return cell
    }
}

extension SearchSuggestionsViewController /* UITableViewDelegate */ {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let text = state.value(from: indexPath) else {
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
