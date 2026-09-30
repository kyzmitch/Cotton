//
//  Data+CatowserExtension.swift
//  CoreBrowser
//
//  Created by Andrei Ermoshin on 22/04/2019.
//  Copyright © 2019 Cotton (former Catowser). All rights reserved.
//

import Foundation
import CottonLoggerKit

extension Data {
    static func dataFrom(_ value: Any) -> Data? {
        guard let jsArrayString =  value as? String else {
            CottonLogger.plugins.warning("js value is not a string")
            return nil
        }
        guard let jsonObject = jsArrayString.data(using: .utf8, allowLossyConversion: true) else {
            CottonLogger.plugins.error("failed to convert string to data")
            return nil
        }
        return jsonObject
    }
}
