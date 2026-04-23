//
//  ReplaceSelectedTabUseCase.swift
//  CoreBrowser
//
//  Created by Andrey Ermoshin on 04.01.2024.
//  Copyright © 2024 Cotton (former Catowser). All rights reserved.
//

import AutoMockable
import CoreBrowser
import BaseUseCaseKit

/// Replace selected tab use case.
public protocol ReplaceSelectedTabUseCase: CoreUseCase, AutoMockable, Sendable {
    /// Replaces currently active tab by combining two operations
    ///
    /// - Parameter tabContent: A tab content to replace with
    func execute(input: CoreBrowser.Tab.ContentType) async throws
}