//
//  CloseAllTabsUseCase.swift
//  CoreBrowser
//
//  Created by Andrey Ermoshin on 04.01.2024.
//  Copyright © 2024 Cotton (former Catowser). All rights reserved.
//

import AutoMockable
import BaseUseCaseKit
import CottonTabs

// MARK: - Interface

/// Close all tabs use case.
public protocol CloseAllTabsUseCase: CoreUseCase, AutoMockable, Sendable
where Input == Void, Output == Void { }

// MARK: - Implementation

public final class CloseAllTabsUseCaseImpl: CloseAllTabsUseCase {
    private let tabsDataService: any TabsDataServiceProtocol

    public init(_ tabsDataService: any TabsDataServiceProtocol) {
        self.tabsDataService = tabsDataService
    }

    public func execute(input: Void) async throws {
        let serviceData = await tabsDataService.sendCommand(.closeAll, nil)
        guard case let .finished(result) = serviceData.allTabsClosed else {
            throw AppError.commandNotFinishedYet
        }
        switch result {
        case .failure(let error):
            throw AppError.tabsServiceError(error)
        case .success:
            return
        }
    }
}
