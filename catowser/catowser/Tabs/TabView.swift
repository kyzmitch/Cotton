//
//  TabView.swift
//  catowser
//
//  Created by admin on 12/06/2017.
//  Copyright © 2017 andreiermoshin. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import CoreGraphics

protocol TabDelegate: class {
    func tab(_ tab: TabView, didPressCloseButton wasActive: Bool) -> Void
    func tab(_ tab: TabView, didBecomeActive active: Bool) -> Void
}

enum TabVisualState {
    case selected, deselected
}

class TabView: UIControl {
    
    public var modelView: TabViewModel? {
        willSet {
            if let mv = newValue {
                
                switch visualState {
                case .deselected:
                    applyColoursFrom(mv, for: .deselected)
                    break
                case .selected:
                    applyColoursFrom(mv, for: .selected)
                    break
                }
                titleText.text = mv.preparedTitle()
            }
        }
    }
    
    private func applyColoursFrom(_ modelView: TabViewModel, for visualState: TabVisualState) {
        switch visualState {
        case .deselected:
            centerBackground.backgroundColor = modelView.backgroundColourDeselected
            backgroundColor = modelView.realBackgroundColour
            rightCurve.curveColour = modelView.tabCurvesColourDeselected
            leftCurve.curveColour = modelView.tabCurvesColourDeselected
            titleText.textColor = modelView.titleColourDeselected
            break
        case .selected:
            centerBackground.backgroundColor = modelView.backgroundColourSelected
            backgroundColor = modelView.realBackgroundColour
            rightCurve.curveColour = modelView.tabCurvesColourSelected
            leftCurve.curveColour = modelView.tabCurvesColourSelected
            titleText.textColor = modelView.titleColourSelected
            break
        }
        rightCurve.setNeedsDisplay()
        leftCurve.setNeedsDisplay()
    }
    
    public var visualState: TabVisualState {
        didSet {
            if oldValue == visualState {
                return
            }
            switch visualState {
            case .deselected:
                modelView?.selected = false
                isSelected = false
                if let mv = modelView {
                    applyColoursFrom(mv, for: .deselected)
                }
                break
            case .selected:
                modelView?.selected = true
                isSelected = true
                if let mv = modelView {
                    applyColoursFrom(mv, for: .selected)
                }
                break
            }
        }
    }
    
    public weak var delegate: TabDelegate?
    
    fileprivate lazy var rightCurve = SingleCurveView(right: true, backColour: UIColor.clear)
    fileprivate lazy var leftCurve = SingleCurveView(right: false, backColour: UIColor.clear)
    
    lazy var centerBackground: UIView = {
        let centerBackground = UIView()
        return centerBackground
    }()
    
    private let closeButton: ButtonWithDecreasedTouchArea = {
        let closeButton = ButtonWithDecreasedTouchArea()
        closeButton.setImage(UIImage(named: "tabCloseButton-Normal"), for: UIControlState())
        closeButton.tintColor = UIColor.lightGray
        closeButton.imageEdgeInsets = UIEdgeInsets(equalInset: 10.0)
        return closeButton
    }()
    
    private let titleText: UILabel = {
        let titleText = UILabel()
        titleText.textAlignment = NSTextAlignment.left
        titleText.isUserInteractionEnabled = false
        titleText.numberOfLines = 1
        titleText.font = UIFont.boldSystemFont(ofSize: 10.0)
        return titleText
    }()
    
    private let favicon: UIImageView = {
        let favicon = UIImageView()
        favicon.layer.cornerRadius = 2.0
        favicon.layer.masksToBounds = true
        return favicon
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function): has not been implemented")
    }
    
    @objc private func handleClosePressed() -> Void {
        var closedTabSelected: Bool
        if let reallySelected = modelView?.selected {
            closedTabSelected = reallySelected
        }
        else {
            print("\(#function): selected is unknown")
            closedTabSelected = false
        }
        delegate?.tab(self, didPressCloseButton: closedTabSelected)
    }
    
    private func handleTapGesture() -> Void {
        modelView?.selected = true
        delegate?.tab(self, didBecomeActive: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            // TODO: this is not working, need to think more
            let location = touch.location(in: self.superview)
            if self.frame.contains(location) {
                handleTapGesture()
                break
            }
        }
    }
    
    override init(frame: CGRect) {
        visualState = .deselected
        super.init(frame: frame)
        contentMode = .redraw
        
        addSubview(rightCurve)
        addSubview(leftCurve)
        addSubview(centerBackground)
        addSubview(favicon)
        addSubview(titleText)
        addSubview(closeButton)
        
        closeButton.addTarget(self, action: #selector(handleClosePressed), for: .touchUpInside)
        
        rightCurve.snp.makeConstraints { make in
            make.right.equalTo(self)
            make.top.equalTo(self)
            make.bottom.equalTo(self)
            make.width.equalTo(SingleCurveView.CurveWidth)
        }
        leftCurve.snp.makeConstraints { make in
            make.left.equalTo(self)
            make.top.equalTo(self)
            make.bottom.equalTo(self)
            make.width.equalTo(SingleCurveView.CurveWidth)
        }
        centerBackground.snp.makeConstraints { make in
            make.left.equalTo(leftCurve.snp.right)
            make.right.equalTo(rightCurve.snp.left)
            make.top.equalTo(self)
            make.bottom.equalTo(self)
        }
        favicon.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.size.equalTo(18.0)
            make.leading.equalTo(self).offset(10)
        }
        titleText.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.height.equalTo(self)
            make.leading.equalTo(favicon.snp.trailing).offset(10)
            make.trailing.equalTo(closeButton.snp.leading).offset(10)
        }
        closeButton.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.height.equalTo(self.snp.height)
            make.width.equalTo(self.snp.height)
            make.trailing.equalTo(self).offset(-5)
        }
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            if traitCollection.horizontalSizeClass == .compact {
                return CGSize(width: UIConstants.compactTabWidth, height: UIConstants.tabHeight)
            }
            else if traitCollection.horizontalSizeClass == .regular {
                return CGSize(width: UIConstants.regularTabWidth, height: UIConstants.tabHeight)
            }
            else {
                return CGSize(width: UIConstants.tabWidth(), height: UIConstants.tabHeight)
            }
        }
    }
    
    fileprivate class SingleCurveView: UIView {
        static let CurveWidth: CGFloat = 50
        private var right: Bool = true
        public var curveColour: UIColor?
        
        init(right: Bool, backColour: UIColor) {
            self.right = right
            
            super.init(frame: CGRect.zero)
            self.backgroundColor = backColour
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("\(#function): has not been implemented")
        }
        
        override func draw(_ rect: CGRect) {
            super.draw(rect)
            let bezierPath = UIBezierPath.topTabsCurve(frame.width, height: frame.height, direction: right ? .right : .left)
            if let crvClr = curveColour {
                crvClr.setFill()
            }
            else {
                UIColor.gray.setFill()
            }
            bezierPath.fill()
        }
    }
}

enum TopTabsCurveDirection {
    case right
    case left
    case both
}

extension UIBezierPath {
    class func topTabsCurve(_ width: CGFloat, height: CGFloat, direction: TopTabsCurveDirection) -> UIBezierPath {
        let x1: CGFloat = 32.84
        let x2: CGFloat = 5.1
        let x3: CGFloat = 19.76
        let x4: CGFloat = 58.27
        let x5: CGFloat = -12.15
        
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: width, y: height))
        switch direction {
        case .right:
            bezierPath.addCurve(to: CGPoint(x: width-x1, y: 0), controlPoint1: CGPoint(x: width-x3, y: height), controlPoint2: CGPoint(x: width-x2, y: 0))
            bezierPath.addCurve(to: CGPoint(x: 0, y: 0), controlPoint1: CGPoint(x: 0, y: 0), controlPoint2: CGPoint(x: 0, y: 0))
            bezierPath.addCurve(to: CGPoint(x: 0, y: height), controlPoint1: CGPoint(x: 0, y: height), controlPoint2: CGPoint(x: 0, y: height))
            bezierPath.addCurve(to: CGPoint(x: width, y: height), controlPoint1: CGPoint(x: x5, y: height), controlPoint2: CGPoint(x: width-x5, y: height))
        case .left:
            bezierPath.addCurve(to: CGPoint(x: width, y: 0), controlPoint1: CGPoint(x: width, y: 0), controlPoint2: CGPoint(x: width, y: 0))
            bezierPath.addCurve(to: CGPoint(x: x1, y: 0), controlPoint1: CGPoint(x: width-x4, y: 0), controlPoint2: CGPoint(x: x4, y: 0))
            bezierPath.addCurve(to: CGPoint(x: 0, y: height), controlPoint1: CGPoint(x: x2, y: 0), controlPoint2: CGPoint(x: x3, y: height))
            bezierPath.addCurve(to: CGPoint(x: width, y: height), controlPoint1: CGPoint(x: width, y: height), controlPoint2: CGPoint(x: width, y: height))
        case .both:
            bezierPath.addCurve(to: CGPoint(x: width-x1, y: 0), controlPoint1: CGPoint(x: width-x3, y: height), controlPoint2: CGPoint(x: width-x2, y: 0))
            bezierPath.addCurve(to: CGPoint(x: x1, y: 0), controlPoint1: CGPoint(x: width-x4, y: 0), controlPoint2: CGPoint(x: x4, y: 0))
            bezierPath.addCurve(to: CGPoint(x: 0, y: height), controlPoint1: CGPoint(x: x2, y: 0), controlPoint2: CGPoint(x: x3, y: height))
            bezierPath.addCurve(to: CGPoint(x: width, y: height), controlPoint1: CGPoint(x: x5, y: height), controlPoint2: CGPoint(x: width-x5, y: height))
        }
        bezierPath.close()
        bezierPath.miterLimit = 4
        return bezierPath
    }
}

extension UIEdgeInsets {
    init(equalInset inset: CGFloat) {
        top = inset
        left = inset
        right = inset
        bottom = inset
    }
}

private class BezierView: UIView {
    var fillColor: UIColor?
    init() {
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function): has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let fillColor = self.fillColor else {
            return
        }
        let bezierPath = UIBezierPath.topTabsCurve(frame.width, height: frame.height, direction: .both)
        
        fillColor.setFill()
        bezierPath.fill()
    }
}

private class ButtonWithDecreasedTouchArea: UIButton {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // decrease touch area for control in all directions by 20
        
        let area = self.bounds.insetBy(dx: 5, dy: 5)
        return area.contains(point)
    }
}
