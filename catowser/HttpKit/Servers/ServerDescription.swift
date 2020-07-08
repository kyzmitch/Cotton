//
//  ServerDescription.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 10/12/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation

public protocol ServerDescription {
    var hostString: String {get}
    var domain: String {get}
    var scheme: HttpScheme {get}
}

public enum HttpScheme: String {
    case https
    case http
}

extension ServerDescription {
    public var scheme: HttpScheme {
        return .https
    }
}
