//
//  ResolveDNSUseCase.swift
//  CottonData
//
//  Created by Andrey Ermoshin on 27.01.2024.
//  Copyright © 2024 Cotton (former Catowser). All rights reserved.
//

import AutoMockable
import Foundation
import BaseUseCaseKit

/// Resolve domain name use case.
/// 
/// Use cases do not hold any mutable state, so that, any of them can be sendable.
public protocol ResolveDNSUseCase: CoreUseCase, AutoMockable, Sendable {
    func execute(input: URL) async throws -> URL
}
