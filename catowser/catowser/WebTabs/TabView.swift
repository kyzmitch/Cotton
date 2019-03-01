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
import CoreBrowser

protocol TabDelegate: class {
    func tabViewDidClose(_ tabView: TabView, was active: Bool)
    func tabDidBecomeActive(_ tab: Tab)
}

/// The tab view for tablets
final class TabView: UIView {
    
    var viewModel: Tab {
        didSet {
            titleText.text = viewModel.title

            // TODO: add UIImageView for site icon
        }
    }
    
    var visualState: Tab.VisualState {
        // Swift docs: You can name the parameter or use the default parameter name of `oldValue`.
        didSet(previousVisualState) {
            if previousVisualState == visualState {
                return
            }
            viewModel.visualState = visualState
            updateColours()
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
        titleText.textAlignment = .left
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
    
    convenience init(frame: CGRect, tab: Tab, delegate: TabDelegate) {
        self.init(frame: frame)
        viewModel = tab
        visualState = tab.visualState
        // Call function not relying on didSet
        // https://stackoverflow.com/questions/25230780/is-it-possible-to-allow-didset-to-be-called-during-initialization-in-swift
        updateColours()
        titleText.text = viewModel.title
        self.delegate = delegate
    }
    
    override init(frame: CGRect) {
        // set temporarily values before calling required base init
        viewModel = .deselectedBlank
        visualState = viewModel.visualState
        
        super.init(frame: frame)
        // Call function not relying on didSet
        // https://stackoverflow.com/questions/25230780/is-it-possible-to-allow-didset-to-be-called-during-initialization-in-swift
        updateColours()
        titleText.text = viewModel.title
        
        contentMode = .redraw
        addSubview(centerBackground)
        addSubview(favicon)
        addSubview(titleText)
        addSubview(closeButton)
        addSubview(highlightLine)
        
        closeButton.addTarget(self, action: #selector(handleClosePressed), for: .touchUpInside)
        
        centerBackground.snp.makeConstraints { make in
            make.leading.equalTo(self)
            make.trailing.equalTo(self)
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
                return CGSize(width: UIConstants.tabWidth, height: UIConstants.tabHeight)
            }
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        get {
            // NOTE: experimenting with UIResponder methods
            // default is NO
            return false
        }
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
}

private extension TabView {
    func updateColours() {
        centerBackground.backgroundColor = viewModel.backgroundColor
        backgroundColor = viewModel.realBackgroundColour
        highlightLine.isHidden =  viewModel.visualState == .deselected
        titleText.textColor = viewModel.titleColor
    }
    
    @objc func handleClosePressed() -> Void {
        delegate?.tabViewDidClose(self, was: viewModel.visualState == .selected)
    }
    
    func handleTapGesture() -> Void {
        delegate?.tabDidBecomeActive(viewModel)
    }
}

extension UIEdgeInsets {
    init(equalInset inset: CGFloat) {
        self.init()
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
