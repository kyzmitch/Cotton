//
//  GoogleDNSStrategy.swift
//  catowser
//
//  Created by Andrei Ermoshin on 8/6/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import BrowserNetworking
import ReactiveSwift
import Combine
import HttpKit

final class GoogleDNSContext: RestClientContext {
    typealias Response = GoogleDNSOverJSONResponse
    typealias Server = GoogleDnsServer
    
    let client: Client
    let rxSubscriber: HttpKitRxSubscriber
    let subscriber: HttpKitSubscriber
    
    init(_ client: Client,
         _ rxSubscriber: HttpKitRxSubscriber,
         _ subscriber: HttpKitSubscriber) {
        self.client = client
        self.rxSubscriber = rxSubscriber
        self.subscriber = subscriber
    }
}

final class GoogleDNSStrategy: DNSResolvingStrategy {
    typealias Context = GoogleDNSContext
    
    private let context: Context
    
    init(_ context: Context) {
        self.context = context
    }
    
    func domainNameResolvingProducer(_ originalURL: URL) -> SignalProducer<URL, HttpKit.DnsError> {
        context.client.rxResolvedDomainName(in: originalURL, context.rxSubscriber)
    }
    
    func domainNameResolvingPublisher(_ originalURL: URL) -> AnyPublisher<URL, HttpKit.DnsError> {
        context.client.resolvedDomainName(in: originalURL, context.subscriber)
            .eraseToAnyPublisher()
    }
    
    @available(swift 5.5)
    @available(macOS 12, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func domainNameResolvingTask(_ originalURL: URL) async throws -> URL {
        let response = try await context.client.aaResolvedDomainName(in: originalURL)
        return response
    }
}
