//
//  ResponseType.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 4/18/22.
//  Copyright © 2022 Cotton (former Catowser). All rights reserved.
//

import Foundation

public protocol ResponseType: Decodable {
    static var successCodes: [Int] { get }
}

extension ResponseType {
    static var successCodes: [Int] {
        return [200, 201]
    }
}
