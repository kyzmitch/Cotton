//
//  ServiceLocator.swift
//  catowser
//
//  Created by Andrey Ermoshin on 04.01.2024.
//  Copyright © 2024 andreiermoshin. All rights reserved.
//

import Foundation

protocol ServiceLocator: AnyObject {
    func findService<T>() -> T?
}
