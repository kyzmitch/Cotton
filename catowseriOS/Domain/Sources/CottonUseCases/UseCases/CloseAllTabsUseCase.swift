//
//  CloseAllTabsUseCase.swift
//  CoreBrowser
//
//  Created by Andrey Ermoshin on 04.01.2024.
//  Copyright © 2024 Cotton (former Catowser). All rights reserved.
//

import AutoMockable
import BaseUseCaseKit

/// Close all tabs use case.
public protocol CloseAllTabsUseCase: CoreUseCase, AutoMockable, Sendable {
    /// Closes all tabs.
    func execute() async throws
}