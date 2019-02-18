//
//  SearchSuggestClient.swift
//  catowser
//
//  Created by Andrei Ermoshin on 14/02/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import ReactiveSwift
import Alamofire

final class SearchSuggestClient {
    private let searchEngine: SearchEngine

    private let alamofire: SessionManager = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpAdditionalHeaders = SessionManager.default.session.configuration.httpAdditionalHeaders ?? [:]
        return SessionManager(configuration: configuration)
    }()

    private weak var request: Request?

    init(_ searchEngine: SearchEngine) {
        self.searchEngine = searchEngine
    }

    deinit {
        request?.cancel()
    }

    func constructSuggestions(basedOn query: String) -> SignalProducer<[String], SuggestClientError> {
        guard let url = searchEngine.suggestURLForQuery(query) else {
            return SignalProducer(error: .wrongUrl)
        }

        request?.cancel()

        let producer = SignalProducer<[String], SuggestClientError> { [weak self] (observer, _) in
            guard let `self` = self else {
                observer.send(error: .zombyInstance)
                return
            }
            self.request = self.alamofire.request(url)
                .validate(statusCode: 200..<300)
                .responseJSON { response in
                    if let error = response.result.error {
                        observer.send(error: .networkError(error))
                        return
                    }

                    // response example:
                    // ["open",["open office","openvpn","opencv","opengl","openedu","opencart",
                    // "openserver","openssl","opendota"]]
                    guard let array = response.result.value as? [Any], array.count > 1 else {
                        observer.send(error: .noSuggestions)
                        return
                    }

                    guard let suggestions = array[1] as? [String] else {
                        observer.send(error: .invalidResponse)
                        return
                    }

                    observer.send(value: suggestions)
            }
        }

        return producer
    }
}

extension SearchSuggestClient {
    enum SuggestClientError: Error{
        case zombyInstance
        case wrongUrl
        case networkError(Error)
        case noSuggestions
        case invalidResponse
    }
}
