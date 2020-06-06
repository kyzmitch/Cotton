//
//  MasterRouter+LinkTagsDelegate.swift
//  catowser
//
//  Created by Andrei Ermoshin on 6/1/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import UIKit

extension MasterRouter: LinkTagsDelegate {
    func didSelect(type: LinksType, from sourceView: UIView) {
        guard type == .video, let source = dataSource else {
            return
        }
        presentVideoViews(using: source, from: sourceView, and: sourceView.frame)
    }
}
