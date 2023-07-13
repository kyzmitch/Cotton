//
//  DNSResolvingStrategy.swift
//  catowser
//
//  Created by Andrei Ermoshin on 7/29/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import CottonRestKit
import ReactiveSwift
import Combine

public protocol DNSResolvingStrategy: AnyObject {
    associatedtype Context: RestClientContext
    
    init(_ context: Context)
    func domainNameResolvingProducer(_ originalURL: URL) -> SignalProducer<URL, DnsError>
    func domainNameResolvingPublisher(_ originalURL: URL) -> AnyPublisher<URL, DnsError>
    @available(swift 5.5)
    @available(macOS 12, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func domainNameResolvingTask(_ originalURL: URL) async throws -> URL
}
