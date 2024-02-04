//
//  SelectedTabUseCase.swift
//  CoreBrowser
//
//  Created by Andrey Ermoshin on 04.01.2024.
//  Copyright © 2024 Cotton (former Catowser). All rights reserved.
//

import Foundation
import AutoMockable

public protocol SelectedTabUseCase: BaseUseCase, AutoMockable {
    func setSelectedPreview(_ image: Data?) async
}
