//
//  DNSResolver.swift
//  catowser
//
//  Created by Andrei Ermoshin on 7/29/22.
//  Copyright © 2022 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import Foundation
import ReactiveSwift
import Combine
import CottonRestKit

private extension String {
    static let waitingQueueName: String = .queueNameWith(suffix: "dnsResolvingThrottle")
}

typealias DNSResolvingProducer = SignalProducer<URL, DnsError>
typealias DNSResolvingPublisher = AnyPublisher<URL, DnsError>

final class DNSResolver<Strategy> where Strategy: DNSResolvingStrategy {
    let strategy: Strategy
    
    private lazy var waitingQueue = DispatchQueue(label: .waitingQueueName)
    private lazy var waitingScheduler = QueueScheduler(qos: .userInitiated,
                                                       name: .waitingQueueName,
                                                       targeting: waitingQueue)
    
    init(_ strategy: Strategy) {
        self.strategy = strategy
    }
    
    func rxResolveDomainName(_ url: URL) -> DNSResolvingProducer {
        return strategy.domainNameResolvingProducer(url)
            .observe(on: QueueScheduler.main)
    }
    
    func cResolveDomainName(_ url: URL) -> DNSResolvingPublisher {
        return strategy.domainNameResolvingPublisher(url)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
