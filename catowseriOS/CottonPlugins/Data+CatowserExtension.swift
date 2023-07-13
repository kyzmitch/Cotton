//
//  Data+CatowserExtension.swift
//  CoreBrowser
//
//  Created by Andrei Ermoshin on 22/04/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation

extension Data {
    static func dataFrom(_ value: Any) -> Data? {
        guard let jsArrayString =  value as? String else {
            print("js value is not a string")
            return nil
        }
        guard let jsonObject = jsArrayString.data(using: .utf8, allowLossyConversion: true) else {
            print("failed to convert string to data")
            return nil
        }
        return jsonObject
    }
}
