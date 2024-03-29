//
//  TrimmedString.swift
//  CoreBrowser
//
//  Created by Andrei Ermoshin on 5/27/20.
//  Copyright © 2020 Cotton (former Catowser). All rights reserved.
//

import Foundation

/// Constrains `String` value by filtering leading space symbols
/// https://nshipster.com/propertywrapper/#constraining-values
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
