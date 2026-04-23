//
//  CloseTabUseCase.swift
//  CoreBrowser
//
//  Created by Andrey Ermoshin on 04.01.2024.
//  Copyright © 2024 Cotton (former Catowser). All rights reserved.
//

import AutoMockable
import CoreBrowser
import BaseUseCaseKit

/// Close tab use case.
public protocol CloseTabUseCase: CoreUseCase, AutoMockable, Sendable {
    /// Close a tab
    ///
    /// - Parameter tab: A tab to close
    /// - Returns new selected tab identifier if we closed selected tab and auto-selection happened
    func execute(input: CoreBrowser.Tab) async throws -> Tab.ID?
}