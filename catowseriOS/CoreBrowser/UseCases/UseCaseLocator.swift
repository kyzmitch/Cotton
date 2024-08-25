//
//  UseCaseLocator.swift
//  catowser
//
//  Created by Andrey Ermoshin on 04.01.2024.
//  Copyright © 2024 Cotton (former Catowser). All rights reserved.
//

import Foundation

/**
 Service locator for the use cases
 */
public final class UseCaseLocator: LazyServiceLocator {
    public override init() {}

    public override func register<T>(_ recipe: @escaping () -> T) {
        guard T.self is BaseUseCase.Type else {
            return
        }
        super.register(recipe)
    }

    public override func register<T>(_ instance: T) {
        guard instance is BaseUseCase else {
            return
        }
        super.register(instance)
    }

    /// Register an instance of a certain type using a string constant
    /// it is for the types with a generic parameter which are not
    /// convinient to store by specific metatype
    ///
    /// - Parameter instance: an object instance stored in a service locator
    /// - Parameter key: a string key to store an object instance
    public override func registerNamed<T>(_ instance: T, _ key: String) {
        guard instance is BaseUseCase else {
            return
        }
        super.registerNamed(instance, key)
    }

    public override func findService<T>(_ type: T.Type, _ key: String? = nil) -> T? {
        return super.findService(type, key)
    }
}
