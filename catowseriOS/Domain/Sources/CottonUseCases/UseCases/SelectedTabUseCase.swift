//
//  SelectedTabUseCase.swift
//  CoreBrowser
//
//  Created by Andrey Ermoshin on 04.01.2024.
//  Copyright © 2024 Cotton (former Catowser). All rights reserved.
//

import AutoMockable
import Foundation
import CottonTabs
import BaseUseCaseKit

/// Selected tabs use case.
/// Use cases do not hold any mutable state, so that, any of them can be sendable.
public protocol SelectedTabUseCase: CoreUseCase, AutoMockable, Sendable {

    /// Sets the preview image for the selected tab asynchronously.
    ///
    /// - Parameter input: The preview image data, or nil to clear it.
    /// - Returns: Void
    func execute(input: Data?) async throws -> Void
}

public final class SelectedTabUseCaseImpl: SelectedTabUseCase {
    private let tabsDataService: any TabsDataServiceProtocol

    public init(_ tabsDataService: any TabsDataServiceProtocol) {
        self.tabsDataService = tabsDataService
    }

    public func execute(input: Data?) async throws {
        let serviceData = await tabsDataService.sendCommand(.updateSelectedTabPreview(input), nil)
        guard case let .finished(result) = serviceData.tabPreviewUpdated else {
            throw AppError.commandNotFinishedYet
        }
        _ = try result.get()
    }
}
