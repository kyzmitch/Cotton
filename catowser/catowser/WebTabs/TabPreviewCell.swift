//
//  TabPreviewCell.swift
//  catowser
//
//  Created by Andrei Ermoshin on 23/01/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import UIKit
import ReactiveSwift
import CoreBrowser
#if canImport(Combine)
import Combine
#endif

fileprivate extension CGFloat {
    static let cornerRadius = CGFloat(6.0)
    static let closeButtonEdgeInset = CGFloat(7)
    static let textBoxHeight = CGFloat(32.0)
    static let faviconSize = CGFloat(20)
    static let closeButtonSize = CGFloat(32)
}

fileprivate extension UIColor {
    static let cellBackground = #colorLiteral(red: 0.9764705882, green: 0.9764705882, blue: 0.9803921569, alpha: 1)
    static let browserBackground = #colorLiteral(red: 0.9764705882, green: 0.9764705882, blue: 0.9803921569, alpha: 1)
    static let tabTitleText: UIColor = .black
    static let cellCloseButton = #colorLiteral(red: 0.4509803922, green: 0.4509803922, blue: 0.4509803922, alpha: 1)
}

fileprivate extension UIFont {
    static let tabTitleText = UIFont.boldSystemFont(ofSize: 8)
}

fileprivate extension UIBlurEffect.Style {
    static let tabTitleBlur: UIBlurEffect.Style = .extraLight
}

protocol TabPreviewCellDelegate: AnyObject {
    func tabCellDidClose(at index: Int)
}

final class TabPreviewCell: UICollectionViewCell, ReusableItem {

    static let borderWidth: CGFloat = 3

    static func cellHeightForCurrent(_ traitCollection: UITraitCollection) -> CGFloat {
        let shortHeight = CGFloat.textBoxHeight * 6

        if traitCollection.verticalSizeClass == .compact {
            return shortHeight
        } else if traitCollection.horizontalSizeClass == .compact {
            return shortHeight
        } else {
            return CGFloat.textBoxHeight * 8
        }
    }

    /// Index needed to find tab which was closed
    private var tabIndex: Int?

    private weak var delegate: TabPreviewCellDelegate?

    private var siteTitleDisposable: Disposable?
    
    @available(iOS 13.0, *)
    private lazy var imageURLRequestCancellable: AnyCancellable? = nil

    private let backgroundHolder: UIView = {
        let view = UIView()
        view.layer.cornerRadius = .cornerRadius
        view.layer.masksToBounds = true
        view.backgroundColor = .cellBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let screenshotView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.isUserInteractionEnabled = false
        view.backgroundColor = .browserBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleText: UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = false
        label.numberOfLines = 1
        label.font = .tabTitleText
        label.textColor = .tabTitleText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let faviconImageView: UIImageView = {
        let favicon = UIImageView()
        favicon.backgroundColor = UIColor.clear
        favicon.layer.cornerRadius = 2.0
        favicon.layer.masksToBounds = true
        favicon.translatesAutoresizingMaskIntoConstraints = false
        return favicon
    }()

    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "tabClose"), for: [])
        button.imageView?.contentMode = .scaleAspectFit
        button.contentMode = .center
        button.tintColor = .cellCloseButton
        button.imageEdgeInsets = UIEdgeInsets(equalInset: .closeButtonEdgeInset)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let title = UIVisualEffectView(effect: UIBlurEffect(style: .tabTitleBlur))

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)

        contentView.addSubview(backgroundHolder)

        backgroundHolder.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
        backgroundHolder.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
        // https://stackoverflow.com/questions/32981532/difference-between-leftanchor-and-leadinganchor
        // What is the difference between `left` and `leading` anchors
        backgroundHolder.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0).isActive = true
        backgroundHolder.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0).isActive = true

        backgroundHolder.addSubview(self.screenshotView)

        backgroundHolder.addSubview(title)
        title.contentView.addSubview(self.closeButton)
        title.contentView.addSubview(self.titleText)
        title.contentView.addSubview(self.faviconImageView)

        title.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(backgroundHolder)
            make.height.equalTo(CGFloat.textBoxHeight)
        }

        faviconImageView.snp.makeConstraints { make in
            make.leading.equalTo(title.contentView).offset(6)
            make.top.equalTo((.textBoxHeight - .faviconSize) / 2)
            make.size.equalTo(CGFloat.faviconSize)
        }

        titleText.snp.makeConstraints { (make) in
            make.leading.equalTo(faviconImageView.snp.trailing).offset(6)
            make.trailing.equalTo(closeButton.snp.leading).offset(-6)
            make.centerY.equalTo(title.contentView)
        }

        closeButton.snp.makeConstraints { make in
            make.size.equalTo(CGFloat.closeButtonSize)
            make.centerY.trailing.equalTo(title.contentView)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        siteTitleDisposable?.dispose()
    }

    @objc func close() {
        print("tab preview cell \(#function)")
        tabIndex.map { delegate?.tabCellDidClose(at: $0) }
    }

    func configure(with tab: Tab, at index: Int, delegate: TabPreviewCellDelegate) {
        screenshotView.image = tab.preview
        
        titleText.text = tab.title
        siteTitleDisposable?.dispose()
        siteTitleDisposable = tab.titleSignal
            .observe(on: UIScheduler())
            .observeValues { [weak self] siteTitle in
                self?.titleText.text = siteTitle
        }
        
        self.tabIndex = index
        self.delegate = delegate
        guard case let .site(site) = tab.contentType else {
            faviconImageView.image = nil
            return
        }
        
        if #available(iOS 13.0, *) {
            imageURLRequestCancellable?.cancel()
            imageURLRequestCancellable = site.fetchFaviconURL()
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { (completion) in
                    switch completion {
                    case .failure(let error):
                        print("Favicon URL failed for \(site.host.rawValue) \(error.localizedDescription)")
                    default: break
                    }
                }, receiveValue: { [weak self] (url) in
                    self?.faviconImageView.updateImage(fromURL: url)
                })
        } else {
            faviconImageView.updateImage(fromURL: site.faviconURL, cachedImage: site.highQualityFaviconImage)
        }
        
    }
}
