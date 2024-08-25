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
    
    public func register<T: BaseUseCase>(_ recipe: @escaping () -> T) {
        super.register(recipe)
    }
    
    public func register<T: BaseUseCase>(_ instance: T) {
        super.register(instance)
    }

    public func registerNamed<T: BaseUseCase>(_ instance: T, _ key: String) {
        super.registerNamed(instance, key)
    }
    
    public func registerTyped<T: BaseUseCase>(_ instance: T, of type: Any.Type) {
        super.registerTyped(instance, of: type)
    }
}
