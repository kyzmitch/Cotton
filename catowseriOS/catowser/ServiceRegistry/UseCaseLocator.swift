//
//  UseCaseLocator.swift
//  catowser
//
//  Created by Andrey Ermoshin on 04.01.2024.
//  Copyright © 2024 Cotton (former Catowser). All rights reserved.
//

import GenericServiceKit
import CottonUseCases
import BaseUseCaseKit

/// Service locator for the use cases
public final class UseCaseLocator: LazyServiceLocator {
    /// Init
    public override init() {}

    /// Register an instance using a concrete type metadata which can't be determined automatically
    ///
    /// - Parameter instance: an object instance stored in a service locator
    /// - Parameter type: a metatype to use as a unique key
    public func registerTyped<T: CoreUseCase>(_ instance: T, of type: Any.Type) {
        super.registerTyped(instance, of: type)
    }
}
