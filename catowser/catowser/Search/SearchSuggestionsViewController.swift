//
//  SearchSuggestionsViewController.swift
//  catowser
//
//  Created by Andrey Ermoshin on 22/02/2018.
//  Copyright © 2018 andreiermoshin. All rights reserved.
//

import UIKit
import HttpKit
import CoreBrowser
import ReactiveSwift
#if canImport(Combine)
import Combine
#endif
#if canImport(_Concurrency)
// this won't be needed after Swift 5.5 will be released
import _Concurrency
#endif

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
    
    private let googleClient: GoogleSuggestionsClient
    
    private let waitingQueueName: String = .queueNameWith(suffix: "searchThrottle")
    
    private lazy var waitingScheduler = QueueScheduler(qos: .userInitiated,
                                                       name: waitingQueueName,
                                                       targeting: waitingQueue)
    
    private lazy var waitingQueue = DispatchQueue(label: waitingQueueName)
    
    init(_ suggestionsHttpClient: GoogleSuggestionsClient) {
        googleClient = suggestionsHttpClient
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func prepareSearch(for searchText: String) {
        suggestions.removeAll()
        knownDomains = InMemoryDomainSearchProvider.shared.domainNames(whereURLContains: searchText)
        if #available(iOS 15.0, *) {
            async { await aaPrepareSearch(for: searchText) }
        } else if #available(iOS 13.0, *) {
            combinePrepareSearch(for: searchText)
        } else {
            rxPrepareSearch(for: searchText)
        }
    }
    
    @Sendable
    @available(iOS 15.0, *)
    private func getSearchSuggestions(for searchText: String) async throws -> [String] {
        let response: HttpKit.GoogleSearchSuggestionsResponse
        response = try await googleClient.aaGoogleSearchSuggestions(for: searchText)
        return response.textResults
    }
    
    @MainActor
    private func updateSuggestions(_ suggestions: [String]) async {
        self.suggestions = suggestions
    }
    
    @available(iOS 15.0, *)
    private func aaPrepareSearch(for searchText: String) async {
#if swift(>=5.5)
        searchSuggestionTaskHandler?.cancel()
        let taskHandler = detach(priority: .userInitiated) {
            try await self.getSearchSuggestions(for: searchText)
        }
        searchSuggestionTaskHandler = taskHandler
        do {
            let strings = try await taskHandler.get()
            await updateSuggestions(strings)
        } catch {
            print("Fail to fetch search suggestions \(error.localizedDescription)")
            await updateSuggestions([])
        }
#else
        assertionFailure("Swift version isn't 5.5 on ios 15")
#endif
    }
    
    @available(iOS 13.0, *)
    private func combinePrepareSearch(for searchText: String) {
        searchSuggestionsCancellable?.cancel()
        let source = Just<String>(searchText)
        searchSuggestionsCancellable = source
            .delay(for: 0.5, scheduler: waitingQueue)
            .mapError({ (_) -> HttpKit.HttpError in
                // workaround to be able to compile case when `Just` has no error type for Failure
                // but it is required to be able to use `flatMap` in next call
                // another option is to use custom publisher which supports non Never Failure type
                return HttpKit.HttpError.zombySelf
            })
            .flatMap({ [weak self] (text) -> HttpKit.CGSearchPublisher in
                guard let self = self else {
                    typealias SuggestionsResult = Result<HttpKit.GoogleSearchSuggestionsResponse, HttpKit.HttpError>
                    let errorResult: SuggestionsResult = .failure(.zombySelf)
                    return errorResult.publisher.eraseToAnyPublisher()
                }
                return self.googleClient.cGoogleSearchSuggestions(for: text)
            })
            .receive(on: DispatchQueue.main)
            .map { $0.textResults }
            .catch({ (failure) -> Just<[String]> in
                print("Fail to fetch search suggestions \(failure.localizedDescription)")
                return .init([])
            })
            .assign(to: \.suggestions, on: self)
    }
    
    private func rxPrepareSearch(for searchText: String) {
        searchSuggestionsDisposable?.dispose()
        let source = SignalProducer<String, Never>.init(value: searchText)
        searchSuggestionsDisposable = source
            .delay(0.5, on: waitingScheduler)
            .flatMap(.latest, { [weak self] (text) -> HttpKit.GSearchProducer in
                guard let self = self else {
                    return .init(error: .zombySelf)
                }
                return self.googleClient.googleSearchSuggestions(for: text)
            })
            .observe(on: QueueScheduler.main)
            .startWithResult { [weak self] (result) in
                switch result {
                case .success(let response):
                    self?.suggestions = response.textResults
                case .failure(let error):
                    print("Fail to fetch search suggestions \(error.localizedDescription)")
                }
        }
    }
    
    @available(iOS 13.0, *)
    private lazy var searchSuggestionsCancellable: AnyCancellable? = nil
    
    @available(iOS 15.0, *)
    private lazy var searchSuggestionTaskHandler: Task.Handle<[String], Error>? = nil
    /// Temporary cancellable needed only for async/await login to be converted to Combine temporarily
    @available(iOS 13.0, *)
    private lazy var searchSuggestionTaskHandlerCancellable: AnyCancellable? = nil
    
    private var searchSuggestionsDisposable: Disposable?

    weak var delegate: SearchSuggestionsListDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        // https://www.hackingwithswift.com/example-code/uikit/how-to-register-a-cell-for-uitableviewcell-reuse
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: .searchSuggestionCellId)
    }
    
    deinit {
        if #available(iOS 13.0, *) {
            searchSuggestionsCancellable?.cancel()
        } else {
            searchSuggestionsDisposable?.dispose()
        }
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
