//
//  SearchSuggestionsViewController.swift
//  SearchSuggestions
//
//  Created by Andrei Ermoshin on 7/03/26.
//  Copyright © 2026 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import UIKit
import Combine
import CottonViewModels

/// Search suggestions controller interface
public protocol SearchSuggestionsControllerInterface: AnyObject {
    /// Prepare search with a query
    /// - Parameter searchQuery: Search query
    func prepareSearch(for searchQuery: String) async
}

/// View controller for suggestions view
/// Looks similar to the one in Safari
public final class SearchSuggestionsViewController: UITableViewController {
    private let viewModel: any SearchSuggestionsViewModel

    private var state: SearchSuggestionsViewState = .waitingForQuery {
        didSet {
            tableView.reloadData()
        }
    }

    /// Combine cancellable for Concurrency Published property
    private var taskHandler: AnyCancellable?
    /// Delegate to handle suggestion selection
    private weak var delegate: SearchSuggestionsListDelegate?

    public init(
        _ delegate: SearchSuggestionsListDelegate?,
        _ viewModel: any SearchSuggestionsViewModel
    ) {
        self.viewModel = viewModel
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        // https://www.hackingwithswift.com/example-code/uikit/how-to-register-a-cell-for-uitableviewcell-reuse
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: .searchSuggestionCellId)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        taskHandler?.cancel()
        taskHandler = viewModel.statePublisher.sink(receiveValue: onStateChange)

        // Also would be good to observe for the changes in settings
        // to notify user to close and open this search table
        // to re-create view model with recently selected auto complete source.
        // Need to update FeatureManager enum features
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        taskHandler?.cancel()
    }

    private func onStateChange(_ state: SearchSuggestionsViewState) {
        guard self.state != state else {
            return
        }
        self.state = state
    }
}

// MARK: - UITableViewDataSource

extension SearchSuggestionsViewController {
    public override func numberOfSections(in tableView: UITableView) -> Int {
        state.sectionsNumber
    }

    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        state.sectionTitle(section: section)
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        state.rowsCount(section)
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: .searchSuggestionCellId, for: indexPath)
        cell.textLabel?.text = state.value(from: indexPath.row, section: indexPath.section)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension SearchSuggestionsViewController {
    public override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let text = state.value(from: indexPath.row, section: indexPath.section) else {
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
        Task {
            try? await delegate?.searchSuggestionDidSelect(content)
        }
    }
}

// MARK: - SearchSuggestionsControllerInterface

extension SearchSuggestionsViewController: SearchSuggestionsControllerInterface {
    public func prepareSearch(for searchQuery: String) async {
        await viewModel.fetchSuggestions(searchQuery)
    }
}

private extension String {
    static let searchSuggestionCellId = "SearchSuggestionCellId"
}

