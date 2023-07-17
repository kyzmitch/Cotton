//
//  TabView.swift
//  catowser
//
//  Created by admin on 12/06/2017.
//  Copyright © 2017 andreiermoshin. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import CoreBrowser
import CottonBase
import FeaturesFlagsKit
#if canImport(Combine)
import Combine
#endif
import BrowserNetworking

protocol TabDelegate: AnyObject {
    func tabViewDidClose(_ tabView: TabView)
    func tabDidBecomeActive(_ tab: Tab)
}

/// The tab view for tablets
final class TabView: UIView {
    
    var viewModel: Tab {
        didSet {
            visualState = viewModel.getVisualState(TabsListManager.shared.selectedId)
            titleText.text = viewModel.title
            reloadFavicon(viewModel.site)
        }
    }
    
    /// Allows change visual state without changing view model
    var visualState: Tab.VisualState {
        // Swift docs: You can name the parameter or use the default parameter name of `oldValue`.
        didSet(previousVisualState) {
            if previousVisualState == visualState {
                return
            }
            updateColours()
        }
    }
    
    weak var delegate: TabDelegate?
    
    private lazy var centerBackground: UIView = {
        let centerBackground = UIView()
        centerBackground.translatesAutoresizingMaskIntoConstraints = false
        return centerBackground
    }()
    
    private let closeButton: ButtonWithDecreasedTouchArea = {
        let closeButton = ButtonWithDecreasedTouchArea()
        closeButton.setImage(UIImage(named: "tabCloseButton-Normal"), for: UIControl.State())
        closeButton.tintColor = UIColor.lightGray
        closeButton.imageEdgeInsets = UIEdgeInsets(equalInset: 10.0)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        return closeButton
    }()
    
    private let titleText: UILabel = {
        let titleText = UILabel()
        titleText.textAlignment = .left
        titleText.isUserInteractionEnabled = false
        titleText.numberOfLines = 1
        titleText.font = UIFont.boldSystemFont(ofSize: 10.0)
        titleText.translatesAutoresizingMaskIntoConstraints = false
        return titleText
    }()
    
    private let faviconImageView: UIImageView = {
        let favicon = UIImageView()
        favicon.layer.cornerRadius = 2.0
        favicon.layer.masksToBounds = true
        favicon.translatesAutoresizingMaskIntoConstraints = false
        return favicon
    }()
    
    private let highlightLine: UIView = {
        let line = UIView()
        line.backgroundColor = UIConstants.webSiteTabHighlitedLineColour
        line.isHidden = true
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()
    
    lazy var imageURLRequestCancellable: AnyCancellable? = nil
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function): has not been implemented")
    }
    
    convenience init(frame: CGRect, tab: Tab, delegate: TabDelegate) {
        self.init(frame: frame)
        // didSet for view model won't work in init
        viewModel = tab
        // Call function not relying on didSet
        // swiftlint:disable:next line_length
        // https://stackoverflow.com/questions/25230780/is-it-possible-to-allow-didset-to-be-called-during-initialization-in-swift
        updateColours()
        titleText.text = tab.title
        self.delegate = delegate
        reloadFavicon(tab.site)
    }
    
    override init(frame: CGRect) {
        // set temporarily values before calling required base init
        viewModel = .blank
        visualState = viewModel.getVisualState(TabsListManager.shared.selectedId)
        
        super.init(frame: frame)
        updateColours()
        titleText.text = viewModel.title
        
        contentMode = .redraw
        addSubview(centerBackground)
        addSubview(faviconImageView)
        addSubview(titleText)
        addSubview(closeButton)
        addSubview(highlightLine)
        
        closeButton.addTarget(self,
                              action: #selector(handleClosePressed),
                              for: .touchUpInside)
        
        centerBackground.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        centerBackground.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        centerBackground.topAnchor.constraint(equalTo: topAnchor).isActive = true
        centerBackground.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        faviconImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        faviconImageView.widthAnchor.constraint(equalToConstant: 18).isActive = true
        faviconImageView.heightAnchor.constraint(equalTo: faviconImageView.widthAnchor).isActive = true
        faviconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        
        titleText.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        titleText.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        titleText.leadingAnchor.constraint(equalTo: faviconImageView.trailingAnchor, constant: 10).isActive = true
        titleText.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: 10).isActive = true
        
        closeButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        closeButton.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        closeButton.widthAnchor.constraint(equalTo: heightAnchor).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5).isActive = true
        
        highlightLine.topAnchor.constraint(equalTo: topAnchor).isActive = true
        highlightLine.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -2).isActive = true
        highlightLine.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 2).isActive = true
        highlightLine.heightAnchor.constraint(equalToConstant: .highlightLineWidth).isActive = true
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            if traitCollection.horizontalSizeClass == .compact {
                return CGSize(width: .compactTabWidth, height: .tabHeight)
            } else if traitCollection.horizontalSizeClass == .regular {
                return CGSize(width: .regularTabWidth, height: .tabHeight)
            } else {
                return CGSize(width: .tabWidth, height: .tabHeight)
            }
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        get {
            // NOTE: experimenting with UIResponder methods, default is NO
            return false
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            // https://github.com/kyzmitch/Cotton/issues/16
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
        let selectedTabId = TabsListManager.shared.selectedId
        centerBackground.backgroundColor = viewModel.backgroundColor(selectedTabId)
        backgroundColor = viewModel.realBackgroundColour
        highlightLine.isHidden = !viewModel.isSelected(selectedTabId)
        titleText.textColor = viewModel.titleColor(selectedTabId)
    }
    
    @objc func handleClosePressed() {
        delegate?.tabViewDidClose(self)
    }
    
    func handleTapGesture() {
        // Can mark it as selected on view layer right away
        // with following code `visualState = .selected`
        // but still need to update same state for
        // previously selected tab (deselect it)
        delegate?.tabDidBecomeActive(viewModel)
    }
    
    func reloadFavicon(_ site: Site?) {
        guard let site = site else {
            faviconImageView.image = nil
            return
        }
        if let hqImage = site.favicon() {
            faviconImageView.image = hqImage
            return
        }
        faviconImageView.image = nil
        
        Task {
            let asyncApi = await FeatureManager.shared.appAsyncApiTypeValue()
            let useDoH = await FeatureManager.shared.boolValue(of: .dnsOverHTTPSAvailable)
            await MainActor.run {
                reloadImageWith(site, asyncApi, useDoH)
            }
        }
    }
    
    private func reloadImageWith(_ site: Site, _ asyncApi: AsyncApiType, _ useDoH: Bool) {
        // TODO: combine with `SiteCollectionViewCell`, `TabPreviewCell` by using common protocol with associated type for image view?
        switch asyncApi {
        case .reactive, .asyncAwait:
            let source: ImageSource
            switch (site.faviconURL(useDoH), site.favicon()) {
            case (let url?, nil):
                source = .url(url)
            case (nil, let image?):
                source = .image(image)
            case (let url?, let image?):
                source = .urlWithPlaceholder(url, image)
            default:
                return
            }
            faviconImageView.updateImage(from: source)
        case .combine:
            let subscriber = HttpEnvironment.shared.dnsClientSubscriber

            imageURLRequestCancellable?.cancel()
            imageURLRequestCancellable = site.fetchFaviconURL(useDoH, subscriber)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { (completion) in
                    switch completion {
                    case .failure:
                        // print("Favicon URL failed for \(site.host.rawValue) \(error.localizedDescription)")
                        break
                    default: break
                    }
                }, receiveValue: { [weak self] (url) in
                    self?.faviconImageView.updateImage(from: .url(url))
                })
        }
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
