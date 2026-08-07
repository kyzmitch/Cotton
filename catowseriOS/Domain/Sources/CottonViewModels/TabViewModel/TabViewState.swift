//
//  TabViewState.swift
//  CottonViewModels
//
//  Created by Andrei Ermoshin on 7/22/23.
//  Copyright © 2023 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import Foundation
import UIKit
import ViewModelKit

public enum ImageSource: @unchecked Sendable {
    case url(URL)
    case image(UIImage)
    case urlWithPlaceholder(URL, UIImage)
}

extension ImageSource: Equatable {
    public static func == (lhs: ImageSource, rhs: ImageSource) -> Bool {
        switch (lhs, rhs) {
        case (.url(let left), .url(let right)):
            return left == right
        case (.image(let left), .image(let right)):
            return left === right
        case (.urlWithPlaceholder(let leftURL, let leftImage), .urlWithPlaceholder(let rightURL, let rightImage)):
            return leftURL == rightURL && leftImage === rightImage
        default:
            return false
        }
    }
}

/// Concrete state type used by the Tab `BaseViewModel` adopter.
public typealias TabState = TabViewState<TabStateContextProxy>

public struct TabViewState<C: TabStateContext>: ViewModelState, @unchecked Sendable {
    public typealias Context = C
    public typealias Action = TabAction
    public typealias BaseState = TabViewState<C>

    public let backgroundColor: UIColor
    public let realBackgroundColour: UIColor
    public let isSelected: Bool
    public let titleColor: UIColor
    public let title: String
    public let favicon: ImageSource?

    public init(
        _ backgroundColor: UIColor,
        _ realBackgroundColour: UIColor,
        _ isSelected: Bool,
        _ titleColor: UIColor,
        _ title: String,
        _ favicon: ImageSource?
    ) {
        self.backgroundColor = backgroundColor
        self.realBackgroundColour = realBackgroundColour
        self.isSelected = isSelected
        self.titleColor = titleColor
        self.title = title
        self.favicon = favicon
    }

    public static func createInitial() -> BaseState {
        .deSelected("", nil)
    }

    static func selected(
        _ title: String,
        _ newFavicon: ImageSource?
    ) -> TabViewState<C> {
        TabViewState(
            .superLightGray,
            UIColor.clear,
            true,
            .lightGrayText,
            title,
            newFavicon
        )
    }

    static func deSelected(
        _ title: String,
        _ newFavicon: ImageSource?
    ) -> TabViewState<C> {
        .init(
            .normallyLightGray,
            UIColor.clear,
            false,
            .darkGrayText,
            title,
            newFavicon
        )
    }

    func withNew(
        _ title: String,
        _ newFavicon: ImageSource?
    ) -> TabViewState<C> {
        TabViewState(
            backgroundColor,
            realBackgroundColour,
            isSelected,
            titleColor,
            title,
            newFavicon
        )
    }

    func selected() -> TabViewState<C> {
        TabViewState(
            .superLightGray,
            UIColor.clear,
            true,
            .lightGrayText,
            title,
            favicon
        )
    }

    func deSelected() -> TabViewState<C> {
        TabViewState(
            .normallyLightGray,
            UIColor.clear,
            false,
            .darkGrayText,
            title,
            favicon
        )
    }

    public static func == (lhs: TabViewState<C>, rhs: TabViewState<C>) -> Bool {
        lhs.isSelected == rhs.isSelected
            && lhs.title == rhs.title
            && lhs.favicon == rhs.favicon
            && lhs.backgroundColor.isEqual(rhs.backgroundColor)
            && lhs.realBackgroundColour.isEqual(rhs.realBackgroundColour)
            && lhs.titleColor.isEqual(rhs.titleColor)
    }
}

extension TabViewState {
    public enum Error: LocalizedError {
        case missingContext

        public var errorDescription: String? {
            switch self {
            case .missingContext:
                "Tab state context is missing"
            }
        }
    }
}

extension UIColor {
    static let superLightGray = UIColor(
        displayP3Red: 0.96,
        green: 0.96,
        blue: 0.96,
        alpha: 1.0
    )
    static let normallyLightGray = UIColor(
        displayP3Red: 0.71,
        green: 0.71,
        blue: 0.71,
        alpha: 1.0
    )
    static let darkGrayText = UIColor(
        displayP3Red: 0.32,
        green: 0.32,
        blue: 0.32,
        alpha: 1.0
    )
    static let lightGrayText = UIColor(
        displayP3Red: 0.14,
        green: 0.14,
        blue: 0.14,
        alpha: 1.0
    )
}
