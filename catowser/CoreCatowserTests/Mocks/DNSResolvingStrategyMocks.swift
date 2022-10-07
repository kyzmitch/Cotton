//
//  DNSResolvingStrategyMocks.swift
//  CoreCatowserTests
//
//  Created by Andrei Ermoshin on 10/5/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import BrowserNetworking
import ReactiveSwift
import Combine
import HttpKit
import CoreCatowser

final class MockedDNSStrategy: DNSResolvingStrategy {
    public typealias Context = MockedDNSContext
    
    private let context: Context
    private var ipAddress: String
    
    convenience init(_ context: Context, _ address: String) {
        self.init(context)
        ipAddress = address
    }
    
    init(_ context: Context) {
        self.context = context
        ipAddress = "192.168.0.1"
    }
    
    public func domainNameResolvingProducer(_ originalURL: URL) -> SignalProducer<URL, HttpKit.DnsError> {
        // swiftlint:disable:next force_try
        let resolvedURL = try! originalURL.updatedHost(with: ipAddress)
        return SignalProducer(value: resolvedURL)
    }
    
    public func domainNameResolvingPublisher(_ originalURL: URL) -> AnyPublisher<URL, HttpKit.DnsError> {
        let future: Future<URL, HttpKit.DnsError> = .init { [weak self] (promise) in
            guard let self = self else {
                promise(.failure(.zombieSelf))
                return
            }
            // swiftlint:disable:next force_try
            let resolvedURL = try! originalURL.updatedHost(with: self.ipAddress)
            promise(.success(resolvedURL))
        }
        return future.eraseToAnyPublisher()
    }
    
    @available(swift 5.5)
    @available(macOS 12, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    public func domainNameResolvingTask(_ originalURL: URL) async throws -> URL {
        // swiftlint:disable:next force_try
        let resolvedURL = try! originalURL.updatedHost(with: ipAddress)
        return resolvedURL
    }
}
