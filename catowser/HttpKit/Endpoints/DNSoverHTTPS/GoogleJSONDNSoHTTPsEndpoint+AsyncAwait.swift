//
//  GoogleJSONDNSoHTTPsEndpoint+AsyncAwait.swift
//  HttpKit
//
//  Created by Ermoshin Andrey on 20.06.2021.
//  Copyright © 2021 andreiermoshin. All rights reserved.
//

#if swift(>=5.5)

import Foundation

extension HttpKit.Client where Server == HttpKit.GoogleDnsServer {
    @available(swift 5.5)
    @available(macOS 12, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func aaGetIPaddress(ofDomain domainName: String) async throws -> HttpKit.GoogleDNSOverJSONResponse {
        let endpoint: HttpKit.GDNSjsonEndpoint = try .googleDnsOverHTTPSJson(domainName)
        let value = try await self.aaMakePublicRequest(for: endpoint, responseType: endpoint.responseType)
        return value
    }

    @available(swift 5.5)
    @available(macOS 12, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    public func aaResolvedDomainName(in url: URL) async throws -> URL {
        guard let hostString = url.httpHost else {
            throw HttpKit.HttpError.noHostInUrl
        }
            
        let ipAddressResponse = try await self.aaGetIPaddress(ofDomain: hostString)
        return try url.updatedHost(with: ipAddressResponse.ipAddress)
    }
}

#endif