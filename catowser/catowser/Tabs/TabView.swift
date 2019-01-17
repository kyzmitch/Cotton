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

class TabView: UIView {
    
    var modelView: TabViewModel? {
        willSet {
            if let mv = newValue {
                
                switch visualState {
                case .deselected:
                    applyColoursFrom(mv, for: .deselected)
                case .selected:
                    applyColoursFrom(mv, for: .selected)
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
            highlightLine.isHidden = true
            titleText.textColor = modelView.titleColourDeselected
        case .selected:
            centerBackground.backgroundColor = modelView.backgroundColourSelected
            backgroundColor = modelView.realBackgroundColour
            highlightLine.isHidden = false
            titleText.textColor = modelView.titleColourSelected
        }
    }
    
    var visualState: TabVisualState {
        didSet {
            if oldValue == visualState {
                return
            }
            
            let changeVisualState: (Bool) -> Void = { [weak self] (selected: Bool) -> Void in
                guard let strongSelf = self else { return }
                if var mv = strongSelf.modelView {
                    mv.selected = selected
                    strongSelf.applyColoursFrom(mv, for: selected ? .selected : .deselected)
                }
            }
            
            switch visualState {
            case .deselected:
                changeVisualState(false)
            case .selected:
                changeVisualState(true)
            }
        }
    }
    
    weak var delegate: TabDelegate?
    
    private lazy var centerBackground: UIView = {
        let centerBackground = UIView()
        return centerBackground
    }()
    
    private let closeButton: ButtonWithDecreasedTouchArea = {
        let closeButton = ButtonWithDecreasedTouchArea()
        closeButton.setImage(UIImage(named: "tabCloseButton-Normal"), for: UIControl.State())
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
    
    private let highlightLine: UIView = {
        let line = UIView()
        line.backgroundColor = UIConstants.webSiteTabHighlitedLineColour
        line.isHidden = true
        return line
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function): has not been implemented")
    }
    
    override var canBecomeFirstResponder: Bool {
        get {
            // NOTE: experimenting with UIResponder methods
            // default is NO
            return false
        }
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
        
        addSubview(centerBackground)
        addSubview(favicon)
        addSubview(titleText)
        addSubview(closeButton)
        addSubview(highlightLine)
        
        closeButton.addTarget(self, action: #selector(handleClosePressed), for: .touchUpInside)
        
        centerBackground.snp.makeConstraints { make in
            make.left.equalTo(self)
            make.right.equalTo(self)
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
        highlightLine.snp.makeConstraints { make in
            make.top.equalTo(self)
            make.leading.equalTo(self).offset(-2)
            make.trailing.equalTo(self).offset(2)
            make.height.equalTo(UIConstants.highlightLineWidth)
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
}

extension UIEdgeInsets {
    init(equalInset inset: CGFloat) {
        top = inset
        left = inset
        right = inset
        bottom = inset
    }
}

private class ButtonWithDecreasedTouchArea: UIButton {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // decrease touch area for control in all directions by 20
        
        let area = self.bounds.insetBy(dx: 5, dy: 5)
        return area.contains(point)
    }
}
