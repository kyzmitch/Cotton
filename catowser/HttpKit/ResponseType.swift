//
//  ResponseType.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 4/18/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import AutoMockable

public protocol ResponseType: Decodable, AutoMockable {
     static var successCodes: [Int] { get }
}

extension ResponseType {
     static var successCodes: [Int] {
         return [200, 201]
     }
}
