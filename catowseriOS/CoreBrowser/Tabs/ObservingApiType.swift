//
//  ObservingApiType.swift
//  catowser
//
//  Created by Andrey Ermoshin on 14.09.2024.
//  Copyright © 2024 Cotton (Catowser). All rights reserved.
//

/// Which API for observing to use
public enum ObservingApiType: Int, CaseIterable, Sendable {
    /// Observe tabs using own Observer design pattern implementation
    case observerDesignPattern
    /// Observe tabs using ios 17 Observation framework
    case systemObservation
}
