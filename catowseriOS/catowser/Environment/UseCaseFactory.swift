//
//  UseCaseFactory.swift
//  catowser
//
//  Created by Andrey Ermoshin on 20.01.2024.
//  Copyright © 2024 andreiermoshin. All rights reserved.
//

import Foundation
import CoreBrowser
import CottonData

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
            registerSearchAutocompleteUseCases()
            registerDnsResolveUseCases()
        }
        
        func findUseCase<T>(_ type: T.Type) -> T {
            locator.findService(type)!
        }
        
        /// Have to use async functions and actor to be able to get
        /// a reference to data service and also because this
        /// factory should be a singleton as well
        private func registerTabsUseCases() async {
            let dataService = await TabsDataService.shared
            let readUseCase: ReadTabsUseCase = ReadTabsUseCaseImpl(dataService, DefaultTabProvider.shared)
            locator.register(readUseCase)
            let writeUseCase: WriteTabsUseCase = WriteTabsUseCaseImpl(dataService)
            locator.register(writeUseCase)
            let selectedTabUseCase: SelectedTabUseCase = SelectedTabUseCaseImpl(dataService)
            locator.register(selectedTabUseCase)
        }
        
        private func registerSearchAutocompleteUseCases() {
            let googleContext = GoogleContext(HttpEnvironment.shared.googleClient,
                                              HttpEnvironment.shared.googleClientRxSubscriber,
                                              HttpEnvironment.shared.googleClientSubscriber)
            let googleStrategy = GoogleAutocompleteStrategy(googleContext)
            let googleUseCase: any AutocompleteWebSearchUseCase = AutocompleteWebSearchUseCaseImpl(googleStrategy)
            let googleType = (any AutocompleteWebSearchUseCase<GoogleAutocompleteStrategy>).self
            let googleKey: String = "\(googleType))"
            locator.registerNamed(googleUseCase, googleKey)
            
            let ddGoContext = DDGoContext(HttpEnvironment.shared.duckduckgoClient,
                                          HttpEnvironment.shared.duckduckgoClientRxSubscriber,
                                          HttpEnvironment.shared.duckduckgoClientSubscriber)
            let ddGoStrategy = DDGoAutocompleteStrategy(ddGoContext)
            let ddGoUseCase: any AutocompleteWebSearchUseCase = AutocompleteWebSearchUseCaseImpl(ddGoStrategy)
            let ddGoType = (any AutocompleteWebSearchUseCase<DDGoAutocompleteStrategy>).self
            let ddGoKey: String = "\(ddGoType)"
            locator.registerNamed(ddGoUseCase, ddGoKey)
        }
        
        private func registerDnsResolveUseCases() {
            /// It is the same context for any site or view model, maybe it makes sense to use only one
            let googleContext = GoogleDNSContext(HttpEnvironment.shared.dnsClient,
                                                 HttpEnvironment.shared.dnsClientRxSubscriber,
                                                 HttpEnvironment.shared.dnsClientSubscriber)
            
            let googleStrategy = GoogleDNSStrategy(googleContext)
            let googleUseCase: any ResolverDNSUseCase = ResolverDNSUseCaseImpl(googleStrategy)
            locator.register(googleUseCase)
        }
    }
}
