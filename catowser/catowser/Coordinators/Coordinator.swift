//
//  Coordinator.swift
//  catowser
//
//  Created by Andrey Ermoshin on 12.11.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation

protocol Coordinator: AnyObject {
    var vcFactory: any ViewControllerFactory { get }
    var childCoordinators: [any Coordinator] { get }
    func start()
    func stop()
}
