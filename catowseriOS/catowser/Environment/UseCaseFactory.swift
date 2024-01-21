//
//  UseCaseFactory.swift
//  catowser
//
//  Created by Andrey Ermoshin on 20.01.2024.
//  Copyright © 2024 andreiermoshin. All rights reserved.
//

import Foundation
import CoreBrowser

final class UseCaseFactory {
    static func shared() async -> UseCasesHolder {
        if let instance = internalInstance {
            return instance
        }
        let created = await UseCasesHolder()
        internalInstance = created
        return created
    }
    
    static private var internalInstance: UseCasesHolder?
    
    actor UseCasesHolder {
        private let locator: UseCaseLocator
        
        init() async {
            locator = .init()
            await registerTabsUseCases()
        }
        
        func findUseCase<T>(_ type: T.Type) -> T {
            locator.findService(T.self)!
        }
        
        /// Have to use async functions and actor to be able to get
        /// a reference to data service and also because this
        /// factory should be a singleton as well
        private func registerTabsUseCases() async {
            let dataService = await TabsDataService.shared
            let readUseCase = ReadTabsUseCaseImpl(dataService, DefaultTabProvider.shared)
            locator.register(readUseCase)
            let writeUseCase = WriteTabsUseCaseImpl(dataService, readUseCase, DefaultTabProvider.shared)
            locator.register(writeUseCase)
        }
    }
}
