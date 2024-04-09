//
//  UseCaseFactory.swift
//  catowser
//
//  Created by Andrey Ermoshin on 20.01.2024.
//  Copyright © 2024 Cotton (former Catowser). All rights reserved.
//

import Foundation
import CoreBrowser
import CottonData

extension String {
    static let googleAutocompleteUseCase = "googleAutocompleteUseCase"
    static let duckDuckGoAutocompleteUseCase = "duckDuckGoAutocompleteUseCase"
    static let googleResolveDnsUseCase = "googleResolveDnsUseCase"
}

@globalActor
final class UseCaseFactory {
    static let shared = StateHolder()
    
    actor StateHolder {
        private let locator: UseCaseLocator

        init() {
            locator = .init()
        }
        
        func registerUseCases() async {
            await registerTabsUseCases()
            registerSearchAutocompleteUseCases()
            registerDnsResolveUseCases()
        }

        func findUseCase<T>(_ type: T.Type, _ key: String? = nil) -> T {
            // swiftlint:disable:next force_unwrapping
            locator.findService(type, key)!
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
            let googleUseCase: any AutocompleteSearchUseCase = AutocompleteSearchUseCaseImpl(googleStrategy)
            locator.registerNamed(googleUseCase, .googleAutocompleteUseCase)

            let ddGoContext = DDGoContext(HttpEnvironment.shared.duckduckgoClient,
                                          HttpEnvironment.shared.duckduckgoClientRxSubscriber,
                                          HttpEnvironment.shared.duckduckgoClientSubscriber)
            let ddGoStrategy = DDGoAutocompleteStrategy(ddGoContext)
            let ddGoUseCase: any AutocompleteSearchUseCase = AutocompleteSearchUseCaseImpl(ddGoStrategy)
            locator.registerNamed(ddGoUseCase, .duckDuckGoAutocompleteUseCase)
        }

        private func registerDnsResolveUseCases() {
            /// It is the same context for any site or view model, maybe it makes sense to use only one
            let googleContext = GoogleDNSContext(HttpEnvironment.shared.dnsClient,
                                                 HttpEnvironment.shared.dnsClientRxSubscriber,
                                                 HttpEnvironment.shared.dnsClientSubscriber)

            let googleStrategy = GoogleDNSStrategy(googleContext)
            let googleUseCase: any ResolveDNSUseCase = ResolveDNSUseCaseImpl(googleStrategy)
            locator.registerNamed(googleUseCase, .googleResolveDnsUseCase)
        }
    }
}
