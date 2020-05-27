//
//  TrimmedString.swift
//  CoreBrowser
//
//  Created by Andrei Ermoshin on 5/27/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation

@propertyWrapper
public struct LeadingTrimmed {
    private(set) var value: String = ""

    public var wrappedValue: String {
        get { value }
        set { value = newValue.trimmingLeadingSpaces() }
    }

    public init(wrappedValue initialValue: String) {
        self.wrappedValue = initialValue
    }
}
