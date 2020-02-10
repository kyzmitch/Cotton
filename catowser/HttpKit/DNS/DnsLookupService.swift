//
//  DnsLookupService.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 2/10/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation
import ReactiveSwift

public typealias GDnsProducer = SignalProducer<URL, DnsError>

public class DnsLookupService {
    public static let shared: DnsLookupService = .init()
    
    lazy var googleClient: HttpKit.Client<HttpKit.GoogleDnsServer> = {
        let server = HttpKit.GoogleDnsServer()
        return .init(server: server)
    }()
    
    private init() {
    }
    
    public func replaceHostWithIP(inURL url: URL) -> GDnsProducer {
        guard let scheme = url.scheme, (scheme == "http" || scheme == "https") else {
            // return .init(error: .notHttpScheme)
            return .init(value: url)
        }
        
        guard let host = url.host else {
            return .init(error: .noHost)
        }
        return googleClient.getIPaddress(ofDomain: host)
            .mapError { (kitError) -> DnsError in
                return .httpError(kitError)
        }
        .flatMap(.latest) { response -> GDnsProducer in
            guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                return .init(error: .urlComponentsFail)
            }
            components.host = response.ipAddress
            guard let clearURL = components.url else {
                return .init(error: .urlHostReplaceFail)
            }
            return .init(value: clearURL)
        }
    }
}

public enum DnsError: LocalizedError {
    case httpError(HttpKit.HttpError)
    case notHttpScheme
    case noHost
    case urlComponentsFail
    case urlHostReplaceFail
}
