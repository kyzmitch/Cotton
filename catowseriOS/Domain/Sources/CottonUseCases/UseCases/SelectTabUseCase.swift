//
//  SelectTabUseCase.swift
//  CoreBrowser
//
//  Created by Andrey Ermoshin on 04.01.2024.
//  Copyright © 2024 Cotton (former Catowser). All rights reserved.
//

import AutoMockable
import CoreBrowser
import BaseUseCaseKit

/// Select tab use case.
public protocol SelectTabUseCase: CoreUseCase, AutoMockable, Sendable {
    /// Remembers selected tab index. Can fail silently if `tab` is not found in a list.
    ///
    /// - Parameter tab: A tab to select
    func execute(input: CoreBrowser.Tab) async throws
}