//
//  ReplaceSelectedTabUseCase.swift
//  CoreBrowser
//
//  Created by Andrey Ermoshin on 04.01.2024.
//  Copyright © 2024 Cotton (former Catowser). All rights reserved.
//

import AutoMockable
import CoreBrowser
import CottonTabs
import BaseUseCaseKit

/// Replace selected tab use case.
public protocol ReplaceSelectedTabUseCase: CoreUseCase, AutoMockable, Sendable {
    /// Replaces currently active tab by combining two operations
    ///
    /// - Parameter tabContent: A tab content to replace with
    func execute(input: CoreBrowser.Tab.ContentType) async throws
}

public final class ReplaceSelectedTabUseCaseImpl: ReplaceSelectedTabUseCase {
    private let tabsDataService: any TabsDataServiceProtocol

    public init(_ tabsDataService: any TabsDataServiceProtocol) {
        self.tabsDataService = tabsDataService
    }

    public func execute(input tabContent: CoreBrowser.Tab.ContentType) async throws {
        let serviceData = await tabsDataService.sendCommand(
            .replaceContent(tabContent),
            nil
        )
        guard case let .finished(result) = serviceData.tabContentReplaced else {
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
