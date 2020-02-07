//
//  GoogleJSONDNSoHTTPsEndpoint.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 10/26/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import Network
import ReactiveSwift

// https://developers.google.com/speed/public-dns/docs/doh/json

extension HttpKit {
    /**

     RR type can be represented as a number in [1, 65535] or a canonical string (case-insensitive, such as A or aaaa).
     You can use 255 for 'ANY' queries but be aware that this is not a replacement for sending queries for both A
     and AAAA or MX records. Authoritative name servers need not return all records for such queries;
     some do not respond, and others (such as cloudflare.com) return only HINFO.
     
     This is wrapper around `String` type.
     https://twitter.com/nicklockwood/status/1192365612661706752?s=20
     */
    public struct DnsRRType: RawRepresentable {
        public init?(rawValue: String) {
            return nil
        }
        
        public let rawValue: String
        
        public typealias RawValue = String
        
        public init?(_ number: UInt32 = 1) {
            guard (1...65535).contains(number) else {
                return nil
            }
            rawValue = "\(number)"
        }
    }
    public struct GDNSRequestParams {
        /**
         string, required

         The only required parameter. RFC 4343 backslash escapes are accepted.
         */
        let name: DomainName
        /**
         string, default: 1
         */
        let type: DnsRRType
        
        /**
         boolean, default: false

         The CD (Checking Disabled) flag. Use cd=1, or cd=true to disable DNSSEC validation;
         use cd=0, cd=false, or no cd parameter to enable DNSSEC validation.
         */
        let cd: Bool
        
        /**
         string, default: empty

         Desired content type option. Use ct=application/dns-message to receive a binary DNS message
         in the response HTTP body instead of JSON text. Use ct=application/x-javascript to explicitly
         request JSON text. Other content type values are ignored and default JSON content is returned.
         */
        let ct: String
        
        /**
         boolean, default: false

         The DO (DNSSEC OK) flag. Use do=1, or do=true to include DNSSEC records
         (RRSIG, NSEC, NSEC3); use do=0, do=false, or no do parameter to omit DNSSEC records.

         Applications should always handle (and ignore, if necessary) any DNSSEC records in JSON responses
         as other implementations may always include them, and we may change the default behavior for JSON
         responses in the future. (Binary DNS message responses always respect the value of the DO flag.)
         */
        let `do`: Bool
        
        /**
         string, default: empty

         The edns0-client-subnet option. Format is an IP address with a subnet mask.
         Examples: 1.2.3.4/24, 2001:700:300::/48.

         If you are using DNS-over-HTTPS because of privacy concerns, and do not want any part of your IP
         address to be sent to authoritative name servers for geographic location accuracy, use
         edns_client_subnet=0.0.0.0/0. Google Public DNS normally sends approximate network
         information (usually zeroing out the last part of your IPv4 address).
         */
        let ednsClientSubnet: IPv4Address
        
        /**
         string, ignored

         The value of this parameter is ignored. Example: XmkMw~o_mgP2pf.gpw-Oi5dK.

         API clients concerned about possible side-channel privacy attacks using the packet sizes of
         HTTPS GET requests can use this to make all requests exactly the same size by padding requests
         with random data. To prevent misinterpretation of the URL, restrict the padding characters to the
         unreserved URL characters: upper- and lower-case letters, digits, hyphen, period, underscore and tilde.
         */
        let randomPadding: String
        
        public init?(domainName: DomainName) {
            name = domainName
            guard let rrType = DnsRRType() else {
                return nil
            }
            type = rrType
            cd = false
            ct = ""
            self.do = false
            guard let address = IPv4Address("0.0.0.0/0") else {
                return nil
            }
            ednsClientSubnet = address
            randomPadding = ""
        }
        
        var urlQueryItems: [URLQueryItem] {
            let subnetStr = String(data: ednsClientSubnet.rawValue,
                                   encoding: .ascii)
            
            let items: [URLQueryItem] = [
                URLQueryItem(name: "name", value: name.string),
                URLQueryItem(name: "type", value: type.rawValue),
                URLQueryItem(name: "cd", value: "\(cd)"),
                URLQueryItem(name: "ct", value: ct),
                URLQueryItem(name: "do", value: "\(self.do)"),
                URLQueryItem(name: "edns_client_subnet", value: subnetStr),
                URLQueryItem(name: "random_padding", value: randomPadding)
            ]
            return items
        }
    }
}

extension HttpKit {
    typealias GDNSjsonEndpoint = HttpKit.Endpoint<HttpKit.GoogleDNSOverJSONResponse, HttpKit.GoogleDnsServer>
    public typealias GDNSjsonProducer = SignalProducer<HttpKit.GoogleDNSOverJSONResponse, HttpKit.HttpError>
}

extension HttpKit.Endpoint {
    
    static func googleDnsOverHTTPSJson(_ params: HttpKit.GDNSRequestParams) throws -> HttpKit.GDNSjsonEndpoint {
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
        static var successCodes: [Int] {
            return [200]
        }
        
        fileprivate let answer: [Answer]
        
        public let ipAddress: String
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            answer = try container.decode([Answer].self, forKey: .answer)
            guard let firstAddress = answer.first?.ipAddress else {
                throw GoogleDNSEndpointError.emptyAnswers
            }
            ipAddress = firstAddress
        }
        
        fileprivate enum CodingKeys: String, CodingKey {
            case answer = "Answer"
        }
    }
}

extension HttpKit {
    public enum GoogleDNSEndpointError: LocalizedError {
        case emptyAnswers
        
        public var errorDescription: String? {
            return "Google DSN over JSON `\(self)`"
        }
    }
}

fileprivate struct Answer: Decodable {
    // "apple.com.", Always matches name in the Question section
    let name: String
    // Data for A - IP address as text
    let ipAddress: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        ipAddress = try container.decode(String.self, forKey: .ipAddress)
    }
    
    fileprivate enum CodingKeys: String, CodingKey {
        case name
        case ipAddress = "data"
    }
}

extension HttpKit.Client where Server == HttpKit.GoogleDnsServer {
    public func getIPaddress(ofDomain domainName: String) -> HttpKit.GDNSjsonProducer {
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
}
