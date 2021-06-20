//
//  GoogleJSONDNSoHTTPsEndpoint.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 10/26/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
// only for `IPv4Address` type, but it's not possible to store mask in it
// maybe better remove this dependency
// import Network
import ReactiveSwift
#if canImport(Combine)
import Combine
#endif

/// https://tools.ietf.org/id/draft-ietf-doh-dns-over-https-02.txt

public typealias GoogleDnsClient = HttpKit.Client<HttpKit.GoogleDnsServer>

extension HttpKit {
    typealias GDNSjsonEndpoint = HttpKit.Endpoint<GoogleDNSOverJSONResponse, GoogleDnsServer>
    public typealias GDNSjsonProducer = SignalProducer<GoogleDNSOverJSONResponse, HttpError>
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public typealias GDNSjsonPublisher = AnyPublisher<GoogleDNSOverJSONResponse, HttpError>
}

extension HttpKit.Endpoint {
    
    static func googleDnsOverHTTPSJson(_ params: HttpKit.GDNSRequestParams) throws -> HttpKit.GDNSjsonEndpoint {
        /**
         To minimize this risk, send only the HTTP headers required for DoH:
         Host, Content-Type (for POST), and if necessary, Accept.
         User-Agent should be included in any development or testing versions.
         */
        return HttpKit.GDNSjsonEndpoint(method: .get,
                                        path: "resolve",
                                        queryItems: params.urlQueryItems,
                                        headers: nil,
                                        encodingMethod: .queryString)
    }
    
    static func googleDnsOverHTTPSJson(_ domainName: String) throws -> HttpKit.GDNSjsonEndpoint {
        let domainObject = try HttpKit.DomainName(domainName)
        guard let params = HttpKit.GDNSRequestParams(domainName: domainObject) else {
            throw HttpKit.HttpError.missingRequestParameters("google dns params")
        }
        
        return try .googleDnsOverHTTPSJson(params)
    }
}

extension HttpKit {
    public struct GoogleDNSOverJSONResponse: ResponseType {
        /**
         200 OK
         HTTP parsing and communication with DNS resolver was successful,
         and the response body content is a DNS response in either binary or JSON encoding,
         depending on the query endpoint, Accept header and GET parameters.
         */
        static var successCodes: [Int] {
            return [200]
        }
        
        fileprivate let answer: [Answer]
        /**
         Note: An HTTP success may still be a DNS failure.
         Check the DNS response code (JSON "Status" field) for the
         DNS errors SERVFAIL, FORMERR, REFUSED, and NOTIMP.
        */
        let status: Int32
        /// NOERROR - Standard DNS response code (32 bit integer).
        let noError: Int32 = 0
        
        public let ipAddress: String
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            answer = try container.decode([Answer].self, forKey: .answer)
            status = try container.decode(Int32.self, forKey: .status)
            guard status == noError else {
                throw GoogleDNSEndpointError.dnsStatusError(status)
            }
            let ipv4array = answer.filter { $0.recordType.knownCase == .addressRecord }
            guard let firstAddress = ipv4array.first?.ipAddress else {
                throw GoogleDNSEndpointError.emptyAnswers
            }
            ipAddress = firstAddress
        }
        
        fileprivate enum CodingKeys: String, CodingKey {
            case answer = "Answer"
            case status = "Status"
        }
    }
}

extension HttpKit {
    public enum GoogleDNSEndpointError: LocalizedError {
        case emptyAnswers
        case dnsStatusError(Int32)
        case recordTypeParsing(UInt32)
        
        public var errorDescription: String? {
            return "Google DSN over JSON `\(self)`"
        }
    }
}

private struct Answer: Decodable {
    /// "apple.com.", Always matches name in the Question section
    let name: String
    /// https://en.wikipedia.org/wiki/List_of_DNS_record_types
    /// Not sure how many bytes for it
    /// 1 - A - Standard DNS RR type
    /// 99 - SPF - Standard DNS RR type
    let recordType: HttpKit.DnsRR
    /// Data for A - IP address as text or some different thing like `z-p42-instagram.c10r.facebook.com.`
    let ipAddress: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        ipAddress = try container.decode(String.self, forKey: .ipAddress)
        let rr = try container.decode(UInt32.self, forKey: .type)
        guard let dnsRR = HttpKit.DnsRR(rr) else {
            throw HttpKit.GoogleDNSEndpointError.recordTypeParsing(rr)
        }
        recordType = dnsRR
    }
    
    fileprivate enum CodingKeys: String, CodingKey {
        case name
        case ipAddress = "data"
        case type
    }
}

private enum DNSRecordType: UInt32 {
    case addressRecord = 1
    case canonicalName = 5
}

extension HttpKit.DnsRR {
    fileprivate var knownCase: DNSRecordType? {
        return DNSRecordType(rawValue: self.numericValue)
    }
}

extension HttpKit.Client where Server == HttpKit.GoogleDnsServer {
    func rxGetIPaddress(ofDomain domainName: String) -> HttpKit.GDNSjsonProducer {
        let endpoint: HttpKit.GDNSjsonEndpoint
        do {
            endpoint = try .googleDnsOverHTTPSJson(domainName)
        } catch let error as HttpKit.HttpError {
            return HttpKit.GDNSjsonProducer(error: error)
        } catch {
            return HttpKit.GDNSjsonProducer(error: HttpKit.HttpError.failedConstructRequestParameters)
        }
        
        let producer = self.makePublicRequest(for: endpoint, responseType: endpoint.responseType)
        return producer
    }
    
    public func rxResolvedDomainName(in url: URL) -> ResolvedURLProducer {
        return url.rxHttpHost
            .flatMapError({ _ -> SignalProducer<String, HttpKit.HttpError> in
                return .init(error: .failedConstructRequestParameters)
            })
            .flatMap(.latest, { (host) -> HttpKit.GDNSjsonProducer in
                return self.rxGetIPaddress(ofDomain: host)
            })
            .flatMapError({ (kitErr) -> SignalProducer<HttpKit.GoogleDNSOverJSONResponse, HttpKit.DnsError> in
                return .init(error: .httpError(kitErr))
            })
            .flatMap(.latest, { (response) -> ResolvedURLProducer in
                return url.rxUpdatedHost(with: response.ipAddress)
            })
    }
    
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func cGetIPaddress(ofDomain domainName: String) -> HttpKit.GDNSjsonPublisher {
        let endpoint: HttpKit.GDNSjsonEndpoint
        do {
            endpoint = try .googleDnsOverHTTPSJson(domainName)
        } catch let error as HttpKit.HttpError {
            return HttpKit.GDNSjsonPublisher(Future.failure(error))
        } catch {
            return HttpKit.GDNSjsonPublisher(Future.failure(HttpKit.HttpError.failedConstructRequestParameters))
        }
        
        let future = self.cMakePublicRequest(for: endpoint, responseType: endpoint.responseType)
        return future.eraseToAnyPublisher()
    }
    
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func resolvedDomainName(in url: URL) -> AnyPublisher<URL, HttpKit.DnsError> {
        return url.cHttpHost
        .mapError { _ -> HttpKit.HttpError in
            return .failedConstructRequestParameters
        }
        .flatMap { self.cGetIPaddress(ofDomain: $0) }
        .map { $0.ipAddress}
        .mapError { (kitErr) -> HttpKit.DnsError in
            return .httpError(kitErr)
        }
        .flatMap { url.cUpdatedHost(with: $0) }
        .eraseToAnyPublisher()
    }
}
