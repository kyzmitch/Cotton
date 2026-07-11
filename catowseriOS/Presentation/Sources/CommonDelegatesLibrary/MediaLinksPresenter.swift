//
//  MediaLinksPresenter.swift
//  Presentation
//
//  Created by Andrey Ermoshin on 23.02.2026.
//

import UIKit

/// An interface only needed on Tablet layout, tablet's search bar implements it
@MainActor
public protocol MediaLinksPresenter: AnyObject {
    /// Media links did receive
    func didReceiveMediaLinks()
    /// Returns source view and rectangle (could be a download arrow button)
    var downloadsPopoverStartInfo: (UIView, CGRect) { get }
}
