//
//  UseCaseLocator.swift
//  catowser
//
//  Created by Andrey Ermoshin on 04.01.2024.
//  Copyright © 2024 andreiermoshin. All rights reserved.
//

import Foundation

/**
 Service locator for the use cases
 */
final class UseCaseLocator: LazyServiceLocator {
    override func register<T>(_ recipe: @escaping () -> T) {
        guard T.self is BaseUseCase.Type else {
            return
        }
        super.register(recipe)
    }
    
    override func register<T>(_ instance: T) {
        guard T.self is BaseUseCase.Type else {
            return
        }
        super.register(instance)
    }
    
    override func findService<T>() -> T? {
        guard T.self is BaseUseCase.Type else {
            return nil
        }
        return super.findService()
    }
}
