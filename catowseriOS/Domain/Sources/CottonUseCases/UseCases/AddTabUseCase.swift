//
//  AddTabUseCase.swift
//  CoreBrowser
//
//  Created by Andrey Ermoshin on 04.01.2024.
//  Copyright © 2024 Cotton (former Catowser). All rights reserved.
//

import AutoMockable
import CoreBrowser
import CottonTabs
import BaseUseCaseKit

/// Add tab use case.
public protocol AddTabUseCase: CoreUseCase, AutoMockable, Sendable {
    /// Adds tab to memory and storage. CoreBrowser.Tab can be blank or it can contain URL address.
    /// CoreBrowser.Tab will be added no matter what happen, so, function doesn't return any result.
    ///
    /// - Parameter tab: A tab.
    func execute(input: CoreBrowser.Tab) async throws
}

public final class AddTabUseCaseImpl: AddTabUseCase {
    private let tabsDataService: any TabsDataServiceProtocol

    public init(_ tabsDataService: any TabsDataServiceProtocol) {
        self.tabsDataService = tabsDataService
    }

    public func execute(input tab: CoreBrowser.Tab) async throws {
        let serviceData = await tabsDataService.sendCommand(.addTab(tab), nil)
        guard case let .finished(result) = serviceData.tabAdded else {
            throw AppError.commandNotFinishedYet
        }
        switch result {
        case .failure(let error):
            throw error
        case .success:
            return
        }
    }
}
