//
//  UIFrameworkType.swift
//  Presentation
//
//  Created by Andrey Ermoshin on 23.02.2026.
//

/// UI framework type
public enum UIFrameworkType: Int, CaseIterable {
    /// Good old UIKit views
    case uiKit
    /// SwiftUI view wraps UIKit view controller
    case swiftUIWrapper
    /// Clear SwiftUI views without re-using UIKit
    case swiftUI

    /// Is it SwiftUI based framework
    public var swiftUIBased: Bool {
        switch self {
        case .swiftUI, .swiftUIWrapper:
            return true
        case .uiKit:
            return false
        }
    }

    /// Fully without UIKit
    public var isUIKitFree: Bool {
        self == .swiftUI
    }

    /// Is it UIKit based framework
    public var uiKitBased: Bool {
        switch self {
        case .uiKit, .swiftUIWrapper:
            return true
        case .swiftUI:
            return false
        }
    }
}
