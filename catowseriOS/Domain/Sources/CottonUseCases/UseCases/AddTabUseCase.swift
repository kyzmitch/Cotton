//
//  AddTabUseCase.swift
//  CoreBrowser
//
//  Created by Andrey Ermoshin on 04.01.2024.
//  Copyright © 2024 Cotton (former Catowser). All rights reserved.
//

import AutoMockable
import CoreBrowser
import BaseUseCaseKit

/// Add tab use case.
public protocol AddTabUseCase: CoreUseCase, AutoMockable, Sendable {
    /// Adds tab to memory and storage. CoreBrowser.Tab can be blank or it can contain URL address.
    /// CoreBrowser.Tab will be added no matter what happen, so, function doesn't return any result.
    ///
    /// - Parameter tab: A tab.
    func execute(input: CoreBrowser.Tab) async throws
}