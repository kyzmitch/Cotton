//
//  TabsSubject.swift
//  CoreBrowser
//
//  Created by Andrei Ermoshin on 5/30/22.
//  Copyright © 2022 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import Foundation

public enum TabSubjectError: Error {
    case tabSelectionFailure
}

public protocol TabsSubject: Actor {
    /// Add tabs observer. Notifies the new observer right away with existing data if needed.
    /// - Parameter observer: A new observer to notify from this subject
    /// - Parameter notify: Tells if newly added observer needs to be notified right away
    func attach(_ observer: TabsObserver, notify: Bool) async
    /// Removes tabs observer.
    func detach(_ observer: TabsObserver) async
}
