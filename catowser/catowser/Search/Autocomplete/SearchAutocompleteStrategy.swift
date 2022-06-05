//
//  SearchAutocompleteStrategy.swift
//  catowser
//
//  Created by Andrei Ermoshin on 6/5/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import HttpKit
import ReactiveSwift
import Combine

protocol SearchAutocompleteStrategy: AnyObject {
    associatedtype Response: ResponseType
    associatedtype Context: SearchAutocompleteContext
    
    init(_ context: Context)
    func suggestionsProducer(for text: String) -> SignalProducer<Context.Response, HttpKit.HttpError>
    func suggestionsPublisher(for text: String) -> AnyPublisher<Context.Response, HttpKit.HttpError>
}
