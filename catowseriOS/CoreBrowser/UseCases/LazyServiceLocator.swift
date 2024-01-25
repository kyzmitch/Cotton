//
//  LazyServiceLocator.swift
//  catowser
//
//  Created by Andrey Ermoshin on 04.01.2024.
//  Copyright © 2024 andreiermoshin. All rights reserved.
//

import Foundation

/// Registry record
enum ServiceRecord {
    case instance(Any)
    case fromClosure(() -> Any)
    
    func unwrap() -> Any {
        switch self {
            case .instance(let instance):
                return instance
            case .fromClosure(let recipe):
                return recipe()
        }
    }
}

public class LazyServiceLocator: ServiceLocator {
    /// Service registry
    private lazy var registry: [String: ServiceRecord] = [:]

    private func typeName(_ some: Any) -> String {
        return (some is Any.Type) ? "\(some)" : "\(type(of: some))"
    }

    public func register<T>(_ recipe: @escaping () -> T) {
        let key = typeName(T.self)
        registry[key] = .fromClosure(recipe)
    }

    public func register<T>(_ instance: T) {
        let key = typeName(T.self)
        registry[key] = .instance(instance)
    }

    public func findService<T>(_ type: T.Type) -> T? {
        let key = typeName(T.self)
        var instance: T? = nil
        if let registryRec = registry[key] {
            instance = registryRec.unwrap() as? T
            /// Replace the recipe with the produced instance if this is the case
            switch registryRec {
                case .fromClosure:
                    if let instance = instance {
                        register(instance)
                    }
                default:
                    break
            }
        }
        return instance
    }
}
