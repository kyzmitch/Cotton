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

/// Close all tabs use case.
public protocol CloseAllTabsUseCase: CoreUseCase, AutoMockable, Sendable {
    /// Input is nothing
    typealias Input = Void
    /// Output is nothing
    typealias Output = Void
}

public final class CloseAllTabsUseCaseImpl: CloseAllTabsUseCase {
    private let tabsDataService: any TabsDataServiceProtocol

    public init(_ tabsDataService: any TabsDataServiceProtocol) {
        self.tabsDataService = tabsDataService
    }

    public func execute(input: Void) async throws -> Void  {
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
