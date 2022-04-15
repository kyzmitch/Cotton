//
//  ServerDescription.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 10/12/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

// gryphon output: ../CoreHttpKit/src/nativeMain/kotlin/ServerDescription.kt
// gryphon insert: package org.cottonweb.CoreHttpKit

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
