//
//  DataServiceKitError.swift
//  GenericServiceKit
//
//  Created by Andrey Ermoshin on 26.11.2024.
//  Copyright © 2024 Cotton (Catowser). All rights reserved.
//

import Foundation

/// Common interface for a data service errors
public protocol DataServiceKitError: LocalizedError, Sendable, Equatable {
    /// For convinience, each business logic domain error type
    /// should have an init which could return own zomby instance error
    init(zombyInstance: Bool)
}
