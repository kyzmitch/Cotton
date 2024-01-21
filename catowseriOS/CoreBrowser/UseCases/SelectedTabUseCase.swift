//
//  SelectedTabUseCase.swift
//  CoreBrowser
//
//  Created by Andrey Ermoshin on 04.01.2024.
//  Copyright © 2024 andreiermoshin. All rights reserved.
//

import UIKit

public protocol SelectedTabUseCase: BaseUseCase {
    func setSelectedPreview(_ image: Data?) async
}
