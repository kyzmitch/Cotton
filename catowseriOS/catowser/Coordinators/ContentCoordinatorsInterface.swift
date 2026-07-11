//
//  BrowserContentCoordinators.swift
//  catowser
//
//  Created by Andrey Ermoshin on 27.11.2024.
//  Copyright © 2024 Cotton (Catowser). All rights reserved.
//

import CommonDelegatesLibrary

/// Browser content related coordinators
@MainActor protocol ContentCoordinatorsInterface: AnyObject, Sendable {
    var topSitesCoordinator: TopSitesCoordinator? { get }
    var webContentCoordinator: WebContentCoordinator? { get }
    var globalMenuDelegate: GlobalMenuDelegate? { get }
    var toolbarCoordinator: MainToolbarCoordinator? { get }
    var toolbarPresenter: AnyViewController? { get }
}
