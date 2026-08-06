//
//  MockDNSResolvingStrategy.swift
//  CottonSearchTests
//

import Combine
import CottonRestKit
import CottonSearch
import Foundation
@preconcurrency import ReactiveSwift

final class MockDNSResolvingStrategy: DNSResolvingStrategy, @unchecked Sendable {
    var publisherHandler: ((URL) -> AnyPublisher<URL, DnsError>)?
    private(set) var publisherCalls: [URL] = []

    func domainNameResolvingProducer(_ originalURL: URL) -> SignalProducer<URL, DnsError> {
        preconditionFailure("MockDNSResolvingStrategy.domainNameResolvingProducer should not be called")
    }

    func domainNameResolvingPublisher(_ originalURL: URL) -> AnyPublisher<URL, DnsError> {
        publisherCalls.append(originalURL)
        guard let publisherHandler else {
            preconditionFailure("MockDNSResolvingStrategy.publisherHandler was not set")
        }
        return publisherHandler(originalURL)
    }

    func domainNameResolvingTask(_ originalURL: URL) async throws -> URL {
        preconditionFailure("MockDNSResolvingStrategy.domainNameResolvingTask should not be called")
    }
}
