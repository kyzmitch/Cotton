//
//  GoogleJSONDNSoHTTPsEndpoint.swift
//  BrowserNetworking
//
//  Created by Andrei Ermoshin on 10/26/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import HttpKit
import CottonCoreBaseKit
import ReactiveHttpKit
import ReactiveSwift
#if canImport(Combine)
import Combine
#endif
import Alamofire

/// https://tools.ietf.org/id/draft-ietf-doh-dns-over-https-02.txt

public typealias GoogleDnsClient = RestClient<GoogleDnsServer,
                                              AlamofireReachabilityAdaptee<GoogleDnsServer>,
                                              JSONEncoding>

typealias GDNSjsonEndpoint = Endpoint<GoogleDnsServer>
public typealias GDNSjsonRxSignal = Signal<GoogleDNSOverJSONResponse, HttpError>.Observer
public typealias GDNSjsonRxInterface = RxObserverWrapper<GoogleDNSOverJSONResponse,
                                                         GoogleDnsServer,
                                                         GDNSjsonRxSignal>
public typealias GDNSJsonClientRxSubscriber = RxSubscriber<GoogleDNSOverJSONResponse,
                                                           GoogleDnsServer,
                                                           GDNSjsonRxInterface>
public typealias GDNSJsonClientSubscriber = Sub<GoogleDNSOverJSONResponse,
                                                GoogleDnsServer>
public typealias GDNSjsonProducer = SignalProducer<GoogleDNSOverJSONResponse, HttpError>
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public typealias GDNSjsonPublisher = AnyPublisher<GoogleDNSOverJSONResponse, HttpError>

extension Endpoint where S == GoogleDnsServer {
     
    static func googleDnsOverHTTPSJson(_ params: GDNSRequestParams) throws -> GDNSjsonEndpoint {
        /**
         To minimize this risk, send only the HTTP headers required for DoH:
         Host, Content-Type (for POST), and if necessary, Accept.
         User-Agent should be included in any development or testing versions.
         */
        let frozenEndpoint = GDNSjsonEndpoint(
            httpMethod: .get,
            path: "resolve",
            headers: nil,
            encodingMethod: .QueryString(items: params.urlQueryItems.kotlinArray))
        return frozenEndpoint
    }
    
    static func googleDnsOverHTTPSJson(_ domainName: String) throws -> GDNSjsonEndpoint {
        let domainObject = try DomainName(input: domainName)
        guard let params = GDNSRequestParams(domainName: domainObject) else {
            throw HttpError.missingRequestParameters("google dns params")
        }
        
        return try .googleDnsOverHTTPSJson(params)
    }
}

public struct GoogleDNSOverJSONResponse: ResponseType {
    /**
     200 OK
     HTTP parsing and communication with DNS resolver was successful,
     and the response body content is a DNS response in either binary or JSON encoding,
     depending on the query endpoint, Accept header and GET parameters.
     */
    public static var successCodes: [Int] {
        [200]
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

public enum GoogleDNSEndpointError: LocalizedError {
    case emptyAnswers
    case dnsStatusError(Int32)
    case recordTypeParsing(UInt32)
    
    public var errorDescription: String? {
        return "Google DSN over JSON `\(self)`"
    }
}

private struct Answer: Decodable {
    /// "apple.com.", Always matches name in the Question section
    let name: String
    /// https://en.wikipedia.org/wiki/List_of_DNS_record_types
    /// Not sure how many bytes for it
    /// 1 - A - Standard DNS RR type
    /// 99 - SPF - Standard DNS RR type
    let recordType: DnsRR
    /// Data for A - IP address as text or some different thing like `z-p42-instagram.c10r.facebook.com.`
    let ipAddress: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        ipAddress = try container.decode(String.self, forKey: .ipAddress)
        let rr = try container.decode(UInt32.self, forKey: .type)
        guard let dnsRR = DnsRR(rr) else {
            throw GoogleDNSEndpointError.recordTypeParsing(rr)
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

extension DnsRR {
    fileprivate var knownCase: DNSRecordType? {
        return DNSRecordType(rawValue: self.numericValue)
    }
}

extension RestClient where Server == GoogleDnsServer {
    func rxGetIPaddress(ofDomain domainName: String, _ subscriber: GDNSJsonClientRxSubscriber) -> GDNSjsonProducer {
        let endpoint: GDNSjsonEndpoint
        do {
            endpoint = try .googleDnsOverHTTPSJson(domainName)
        } catch let error as HttpError {
            return GDNSjsonProducer(error: error)
        } catch let coreError as DomainName.Error {
            return GDNSjsonProducer(error: HttpError.invalidDomainName(error: coreError))
        } catch {
            return GDNSjsonProducer(error: HttpError.failedConstructRequestParameters)
        }
        
        let adapter: AlamofireHTTPRxAdaptee<GoogleDNSOverJSONResponse,
                                            GoogleDnsServer,
                                            GDNSjsonRxInterface> = .init(.waitsForRxObserver)
        let producer = self.rxMakePublicRequest(for: endpoint, transport: adapter, subscriber: subscriber)
        return producer
    }
    
    public func rxResolvedDomainName(in url: URL, _ subscriber: GDNSJsonClientRxSubscriber) -> ResolvedURLProducer {
        return url.rxHttpHost
            .flatMapError({ _ -> SignalProducer<String, HttpError> in
                return .init(error: .failedConstructRequestParameters)
            })
            .flatMap(.latest, { (host) -> GDNSjsonProducer in
                return self.rxGetIPaddress(ofDomain: host, subscriber)
            })
            .flatMapError({ (kitErr) -> SignalProducer<GoogleDNSOverJSONResponse, DnsError> in
                return .init(error: .httpError(kitErr))
            })
            .flatMap(.latest, { (response) -> ResolvedURLProducer in
                return url.rxUpdatedHost(with: response.ipAddress)
            })
    }
    
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func cGetIPaddress(ofDomain domainName: String, _ subscriber: GDNSJsonClientSubscriber) -> GDNSjsonPublisher {
        let endpoint: GDNSjsonEndpoint
        do {
            endpoint = try .googleDnsOverHTTPSJson(domainName)
        } catch let error as HttpError {
            return GDNSjsonPublisher(Future.failure(error))
        } catch let coreError as DomainName.Error {
            let adaptedError: HttpError = .invalidDomainName(error: coreError)
            return GDNSjsonPublisher(Future.failure(adaptedError))
        } catch {
            return GDNSjsonPublisher(Future.failure(HttpError.failedConstructRequestParameters))
        }
        
        let adapter: AlamofireHTTPAdaptee<GoogleDNSOverJSONResponse,
                                          GoogleDnsServer> = .init(.waitsForCombinePromise)
        let future = self.cMakePublicRequest(for: endpoint, transport: adapter, subscriber: subscriber)
        return future.eraseToAnyPublisher()
    }
    
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func resolvedDomainName(in url: URL, _ subscriber: GDNSJsonClientSubscriber) -> AnyPublisher<URL, DnsError> {
        return url.cHttpHost
        .mapError { _ -> HttpError in
            return .failedConstructRequestParameters
        }
        .flatMap { self.cGetIPaddress(ofDomain: $0, subscriber) }
        .map { $0.ipAddress}
        .mapError { (kitErr) -> DnsError in
            return .httpError(kitErr)
        }
        .flatMap { url.cUpdatedHost(with: $0) }
        .eraseToAnyPublisher()
    }
}
