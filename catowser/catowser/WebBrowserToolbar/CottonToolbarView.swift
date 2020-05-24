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
    
    override init(frame: CGRect) {
        if frame.width <= 10 {
            // iOS 13.x fix for layout errors for code
            // which works on iOS 13.x on iPad
            // and worked for iOS 12.x for all kind of devices
            
            // swiftlint:disable:next line_length
            // https://github.com/hackiftekhar/IQKeyboardManager/pull/1598/files#diff-f73f23d86e3154de71cd5bd9abf275f0R146
            super.init(frame: CGRect(x: 0, y: 0, width: 1000, height: 44))
        } else {
            super.init(frame: frame)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
