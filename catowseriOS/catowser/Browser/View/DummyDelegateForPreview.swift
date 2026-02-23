//
//  DummyDelegateForPreview.swift
//  catowser
//
//  Created by Andrei Ermoshin on 1/13/23.
//  Copyright © 2023 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import Foundation
import CommonDelegatesLibrary

final class DummyDelegate: ContentCoordinatorsInterface {
    let topSitesCoordinator: TopSitesCoordinator? = nil
    let webContentCoordinator: WebContentCoordinator? =  nil
    let globalMenuDelegate: GlobalMenuDelegate? = nil
    let toolbarCoordinator: MainToolbarCoordinator? = nil
    let toolbarPresenter: AnyViewController? = nil
}
