//
//  AppLayoutCoordinator+LinkTagsDelegate.swift
//  catowser
//
//  Created by Andrei Ermoshin on 6/1/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import UIKit

extension AppLayoutCoordinator: LinkTagsDelegate {
    func didSelect(type: LinksType, from sourceView: UIView) {
        guard type == .video, let source = tagsSiteDataSource else {
            return
        }
        presentVideoViews(using: source, from: sourceView, and: sourceView.frame)
    }
}
