//
//  TabCacheErrors.swift
//  CoreBrowser
//
//  Created by Andrei Ermoshin on 1/4/21.
//  Copyright © 2021 andreiermoshin. All rights reserved.
//

import Foundation

public enum TabResourceError: Swift.Error {
    case zombieSelf
    case storeNotInitializedYet
    case dummyError
    case insertError(Error)
    case deleteError(Error)
    case fetchAllError(Error)
    case selectedTabIndex(Error)
}

public enum TabStorageError: Swift.Error {
    case dbResourceError(TabResourceError)
}
