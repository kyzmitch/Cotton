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
    private lazy var idByRecord: [ObjectIdentifier : ServiceRecord] = [:]
    private lazy var stringByRecord: [String : ServiceRecord] = [:]

    public func register<T>(_ recipe: @escaping () -> T) {
        let key = ObjectIdentifier(type(of: T.self))
        idByRecord[key] = .fromClosure(recipe)
    }

    public func register<T>(_ instance: T) {
        let key = ObjectIdentifier(type(of: instance))
        idByRecord[key] = .instance(instance)
    }
    
    public func registerNamed<T>(_ instance: T, _ key: String) {
        stringByRecord[key] = .instance(instance)
    }

    public func findService<T>(_ type: T.Type, _ key: String? = nil) -> T? {
        let id = ObjectIdentifier(type)
        var instance: T? = nil
        
        /// internal closure
        func handle<B>(_ registryRec: ServiceRecord) -> B? {
            let instance: B? = registryRec.unwrap() as? B
            /// Replace the recipe with the produced instance if this is the case
            switch registryRec {
                case .fromClosure:
                    if let instance = instance {
                        register(instance)
                    }
                default:
                    break
            }
            return instance
        }
        
        if let registryRec = idByRecord[id] {
            instance = handle(registryRec)
        } else if let recordKey = key, let registryRec = stringByRecord[recordKey] {
            instance = handle(registryRec)
        }
        return instance
    }
}
