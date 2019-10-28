//
//  GoogleJSONDNSoHTTPsEndpoint.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 10/26/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation

// https://developers.google.com/speed/public-dns/docs/doh/json

extension HttpKit.Endpoint {
    static func googleDnsOverHTTPSJson(name: HttpKit.DomainName) throws -> HttpKit.GSearchEndpoint {
        throw HttpKit.HttpError.failedConstructRequestParameters
    }
}
