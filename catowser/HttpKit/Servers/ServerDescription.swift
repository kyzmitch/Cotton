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
    var scheme: String {get}
}

extension ServerDescription {
    public var scheme: String {
        return "https"
    }
}

