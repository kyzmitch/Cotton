//
//  UseCaseRegistry.swift
//  catowser
//
//  Created by Andrey Ermoshin on 20.01.2024.
//  Copyright © 2024 Cotton (former Catowser). All rights reserved.
//

import GenericServiceKit
import Foundation
import CoreBrowser
import CottonUseCases
import CottonSearch

/// A global singletone for storing all the use case classes
@globalActor final class UseCaseRegistry {
    static let shared = StateHolder()

    actor StateHolder {
        private let useCaseLocator: UseCaseLocator
        private let serviceRegistry: ServiceRegistry.StateHolder

        init(
            useCaseLocator: UseCaseLocator = UseCaseLocator(),
            serviceRegistry: ServiceRegistry.StateHolder = ServiceRegistry.shared
        ) {
            self.useCaseLocator = useCaseLocator
            self.serviceRegistry = serviceRegistry
        }

        /// Registers all the use cases, usually at the application start
        func registerUseCases() async {
            await registerTabsUseCases()
            await registerSearchAutocompleteUseCases()
            await registerDnsResolveUseCases()
        }

        /// Searches for a specific use case based on a type or a string key
        /// if storing by a type was to complex (if it a type was with a generic params)
        func findUseCase<T>(_ type: T.Type, _ key: String? = nil) -> T {
            // swiftlint:disable:next force_unwrapping
            useCaseLocator.findService(type, key)!
        }

        /// Have to use async functions and actor to be able to get
        /// a reference to data service and also because this
        /// factory should be a singleton as well
        private func registerTabsUseCases() async {
            let dataService = await ServiceRegistry.shared.tabsService

            let addTabUseCase: any AddTabUseCase = AddTabUseCaseImpl(dataService)
            useCaseLocator.registerTyped(
                addTabUseCase,
                of: (any AddTabUseCase).self
            )

            let closeTabUseCase: any CloseTabUseCase = CloseTabUseCaseImpl(dataService)
            useCaseLocator.registerTyped(
                closeTabUseCase,
                of: (any CloseTabUseCase).self
            )

            let closeAllTabsUseCase: any CloseAllTabsUseCase = CloseAllTabsUseCaseImpl(dataService)
            useCaseLocator.registerTyped(
                closeAllTabsUseCase,
                of: (any CloseAllTabsUseCase).self
            )

            let replaceSelectedTabUseCase: any ReplaceSelectedTabUseCase = ReplaceSelectedTabUseCaseImpl(dataService)
            useCaseLocator.registerTyped(
                replaceSelectedTabUseCase,
                of: (any ReplaceSelectedTabUseCase).self
            )

            let selectTabUseCase: any SelectTabUseCase = SelectTabUseCaseImpl(dataService)
            useCaseLocator.registerTyped(
                selectTabUseCase,
                of: (any SelectTabUseCase).self
            )

            // Register ReadAllTabsUseCase
            let readAllTabsUseCase: any ReadAllTabsUseCase = ReadAllTabsUseCaseImpl(dataService)
            useCaseLocator.registerTyped(
                readAllTabsUseCase,
                of: (any ReadAllTabsUseCase).self
            )

            // Register ReadSelectedTabIdUseCase
            let readSelectedTabIdUseCase: any ReadSelectedTabIdUseCase = ReadSelectedTabIdUseCaseImpl(dataService, DefaultTabProvider.shared)
            useCaseLocator.registerTyped(
                readSelectedTabIdUseCase,
                of: (any ReadSelectedTabIdUseCase).self
            )

            // Register ReadTabsCountUseCase
            let readTabsCountUseCase: any ReadTabsCountUseCase = ReadTabsCountUseCaseImpl(dataService)
            useCaseLocator.registerTyped(
                readTabsCountUseCase,
                of: (any ReadTabsCountUseCase).self
            )

            // Register SelectedTabUseCase
            let selectedTabUseCase: any SelectedTabUseCase = SelectedTabUseCaseImpl(dataService)
            useCaseLocator.registerTyped(
                selectedTabUseCase,
                of: (any SelectedTabUseCase).self
            )
        }

        private func registerSearchAutocompleteUseCases() async {
            let searchDataService = await serviceRegistry.findDataService(
                (any SearchDataServiceProtocol).self,
                .searchDataServiceKey
            )
            let createSearchURLUseCase: any CreateSearchURLUseCase = CreateSearchURLUseCaseImpl(searchDataService)
            useCaseLocator.registerTyped(
                createSearchURLUseCase,
                of: (any CreateSearchURLUseCase).self
            )
            let fetchSuggestionsUseCase: any FetchAutocompleteSuggestionsUseCase = FetchAutocompleteSuggestionsUseCaseImpl(searchDataService)
            useCaseLocator.registerTyped(
                fetchSuggestionsUseCase,
                of: (any FetchAutocompleteSuggestionsUseCase).self
            )
        }

        private func registerDnsResolveUseCases() async {
            let searchDataService = await serviceRegistry.findDataService(
                (any SearchDataServiceProtocol).self,
                .searchDataServiceKey
            )
            let googleUseCase: any ResolveDNSUseCase = ResolveDNSUseCaseImpl(searchDataService)
            useCaseLocator.registerTyped(
                googleUseCase,
                of: (any ResolveDNSUseCase).self
            )
        }
    }
}
