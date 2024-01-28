//
//  ResolveDNSUseCase.swift
//  CottonData
//
//  Created by Andrey Ermoshin on 27.01.2024.
//  Copyright © 2024 andreiermoshin. All rights reserved.
//

import Foundation
import CoreBrowser
import ReactiveSwift
import Combine
import CottonRestKit

public typealias DNSResolvingProducer = SignalProducer<URL, DnsError>
public typealias DNSResolvingPublisher = AnyPublisher<URL, DnsError>

public protocol ResolveDNSUseCase<Strategy>: BaseUseCase {
    associatedtype Strategy: DNSResolvingStrategy
    var strategy: Strategy { get }
    func rxResolveDomainName(_ url: URL) -> DNSResolvingProducer
    func cResolveDomainName(_ url: URL) -> DNSResolvingPublisher
    func aaResolveDomainName(_ url: URL) async throws -> URL
}
