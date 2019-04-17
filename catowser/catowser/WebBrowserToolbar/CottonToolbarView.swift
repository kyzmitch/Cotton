//
//  CottonToolbarView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 17/04/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import UIKit

final class CottonToolbarView: UIToolbar {
    var counterView: CounterView?
    var downloadsView: UIImageView?

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard isUserInteractionEnabled else { return nil }

        guard !isHidden else { return nil }

        guard alpha >= 0.01 else { return nil }

        guard self.point(inside: point, with: event) else { return nil }

        if let tabsView = counterView, tabsView.point(inside: convert(point, to: tabsView), with: event) {
            return counterView
        }

        if let dView = downloadsView, dView.point(inside: convert(point, to: downloadsView), with: event) {
            return downloadsView
        }

        for subview in subviews.reversed() {
            let convertedPoint = subview.convert(point, from: self)
            if let candidate = subview.hitTest(convertedPoint, with: event) {
                return candidate
            }
        }

        return super.hitTest(point, with: event)
    }
}
