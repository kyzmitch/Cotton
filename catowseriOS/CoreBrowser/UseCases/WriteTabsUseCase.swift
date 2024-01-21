//
//  WriteTabsUseCase.swift
//  CoreBrowser
//
//  Created by Andrey Ermoshin on 04.01.2024.
//  Copyright © 2024 andreiermoshin. All rights reserved.
//

import Foundation

public protocol WriteTabsUseCase: BaseUseCase {
    /// Adds tab to memory and storage. Tab can be blank or it can contain URL address.
    /// Tab will be added no matter what happen, so, function doesn't return any result.
    ///
    /// - Parameter tab: A tab.
    func add(tab: Tab) async
    /// Closes tab.
    func close(tab: Tab) async
    /// Closes all tabs.
    func closeAll() async
    /// Remembers selected tab index. Can fail silently if `tab` is not found in a list.
    func select(tab: Tab) async
    /// Replaces currently active tab by combining two operations
    func replaceSelected(_ tabContent: Tab.ContentType) async
}
