//
//  SearchBarLegacyView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 12/15/22.
//  Copyright © 2022 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import UIKit
import CoreBrowser
import FeaturesFlagsKit

enum SearchBarConstants {
    static let animationDuration = 0.3
}

final class SearchBarLegacyView: UIView {
    /// Search bar view delegate
    weak var delegate: UISearchBarDelegate? {
        didSet {
            searchBarView.delegate = delegate
        }
    }

    // MARK: - state properties

    private var state: SearchBarState = .blankViewMode {
        didSet {
            onStateChange(state)
        }
    }

    func handleAction(_ action: SearchBarAction) {
        switch action {
        case .startSearch:
            let initialTitle = state.title
            let initialContent = state.content
            state = .inSearchMode(initialTitle, initialContent)
        case .cancelTapped:
            let initialContent = state.content
            if initialContent.isEmpty {
                state = .blankViewMode
            } else {
                state = .viewMode(state.title, initialContent, true)
            }
        case .updateView(let newTitle, let newContent) where !newTitle.isEmpty:
            state = .viewMode(newTitle, newContent, false)
        case .clearView:
            state = .blankViewMode
        default:
            // just in case
            state = .blankViewMode
        }
    }

    let uiFramework: UIFrameworkType

    /// Only needed for SwiftUI wrapper for phone layout
    private var phoneWidthConstraint: NSLayoutConstraint?

    // MARK: - initializers

    init(frame: CGRect, uiFramework: UIFrameworkType) {
        self.uiFramework = uiFramework
        super.init(frame: frame)

        addSubview(searchBarView)
        addSubview(dohStateIcon)

        siteNameLabel.alpha = 0
        dohStateIcon.alpha = 0

        searchBarView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        searchBarView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true

        if isPreviewingSwiftUI {
            if isPad {
                searchBarView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            } else {
                searchBarView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 16).isActive = true
            }
        } else {
            if uiFramework.swiftUIBased {
                // Fix for the SwiftUI preview to have some width, otherwise whole view has 0 width
                // and for some reason in preview mode the super view doesn't tell the width
                if isPad {
                    searchBarView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
                } else {
                    let widthValue = UIScreen.main.bounds.width - 16
                    phoneWidthConstraint = searchBarView.widthAnchor.constraint(equalToConstant: widthValue)
                    phoneWidthConstraint?.isActive = true
                }
            } else {
                searchBarView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            }
        }
        if frame.height > 0 {
            // SwiftUI layout fix because it can't determine the search bar height
            searchBarView.heightAnchor.constraint(equalToConstant: frame.height).isActive = true
        } else {
            searchBarView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }

        dohStateIcon.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        dohStateIcon.topAnchor.constraint(equalTo: topAnchor).isActive = true
        dohStateIcon.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        dohStateIcon.widthAnchor.constraint(equalTo: dohStateIcon.heightAnchor).isActive = true
    }

    func handleTraitCollectionChange() {
        if uiFramework.swiftUIBased && !isPad {
            let widthValue = UIScreen.main.bounds.width - 16
            phoneWidthConstraint?.constant = widthValue
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - layout

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        // Not sure if this is the right place to start layout
        // maybe init is better or it could be a separate state

        siteNameLabel.addGestureRecognizer(siteNameTapGesture)
    }

    // MARK: - subview properties

    /// The search bar view.
    private let searchBarView: UISearchBar = {
        let view = UISearchBar(frame: .zero)
        ThemeProvider.shared.setup(view)
        view.placeholder = .placeholderText
        view.autocapitalizationType = .none
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let siteNameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .black
        label.backgroundColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        label.numberOfLines = 0
        // https://krakendev.io/blog/autolayout-magic-like-harry-potter-but-real
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }()

    private let dohStateIcon: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .black
        label.font = .italicSystemFont(ofSize: 8)
        label.backgroundColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        return label
    }()

    private var showedLabelConstraint: NSLayoutConstraint?
    private func createShowedLabelConstraint() -> NSLayoutConstraint {
        if isPad {
            return siteNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0)
        } else {
            return siteNameLabel.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)
        }
    }

    private lazy var hiddenLabelConstraint: NSLayoutConstraint = {
        if isPad {
            return siteNameLabel.trailingAnchor.constraint(equalTo: leadingAnchor, constant: 0)
        } else {
            return siteNameLabel.widthAnchor.constraint(equalToConstant: 0)
        }
    }()

    private lazy var siteNameTapGesture: UITapGestureRecognizer = {
        // Need to init gesture lazily, if it will  be initialized as a constant
        // then it will not work :( action is not called.
        // Problem is with using `self` inside constant,
        // it seems it is not fully initialized at that point.
        // https://forums.swift.org/t/self-usage-inside-constant-property/21011
        // https://stackoverflow.com/questions/50393312/why-can-i-use-self-when-i-initialize-property-with-a-closure

        let tap = UITapGestureRecognizer(target: self, action: .siteNameTap)
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        return tap
    }()

    @objc func handleSiteNameTap(_ gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer.view != nil else { return }
        guard gestureRecognizer.state == .ended else { return }

        searchBarView.setShowsCancelButton(true, animated: true)
        searchBarView.becomeFirstResponder()
        prepareForEditMode()
    }
}

private extension SearchBarLegacyView {
    // MARK: - state handler

    private func onStateChange(_ nextState: SearchBarState) {
        // See `diff` comment to find a difference with previos state handling

        switch nextState {
        case .blankViewMode:
            searchBarView.text = nil
            siteNameLabel.text = .placeholderText
            searchBarView.setShowsCancelButton(false, animated: false)
            searchBarView.resignFirstResponder()
            // for blank mode it is better to hide label and
            // make search bar frontmost right away
            prepareForEditMode()
        case .inSearchMode:
            searchBarView.setShowsCancelButton(true, animated: true)
            guard searchBarView.text != nil else {
                break
            }
            // need somehow select all text in search bar view
            prepareForEditMode()
        case .viewMode(let title, let searchBarContent, let animated):
            handleViewModeState(title, searchBarContent, animated)
        }
    }

    func prepareForEditMode(and showKeyboard: Bool = false) {
        if siteNameLabel.superview == nil {
            addSubview(siteNameLabel)
            siteNameLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
            siteNameLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            if isPad {
                siteNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            } else {
                siteNameLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            }
        }
        if showedLabelConstraint == nil {
            showedLabelConstraint = createShowedLabelConstraint()
        }
        showedLabelConstraint?.isActive = false
        hiddenLabelConstraint.isActive = true

        if showKeyboard {
            searchBarView.becomeFirstResponder()
        }
        siteNameLabel.alpha = 0
        dohStateIcon.alpha = 0

        UIView.animate(withDuration: SearchBarConstants.animationDuration) {
            self.siteNameLabel.layoutIfNeeded()
            self.searchBarView.alpha = 1
        }
    }

    func prepareForViewMode(animated: Bool = true, animateSecurityView: Bool = false) {
        // Order of disabling/enabling is important
        // to not to cause errors in layout calculation.
        // First need to disable and after that enable new one.
        if siteNameLabel.superview == nil {
            addSubview(siteNameLabel)
            siteNameLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
            siteNameLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            if isPad {
                siteNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            } else {
                siteNameLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            }
        }
        hiddenLabelConstraint.isActive = false
        if showedLabelConstraint == nil {
            showedLabelConstraint = createShowedLabelConstraint()
        }
        showedLabelConstraint?.isActive = true

        func applyLayout() {
            siteNameLabel.layoutIfNeeded()
            searchBarView.alpha = 0
            siteNameLabel.alpha = 1
            if animateSecurityView {
                dohStateIcon.alpha = 1
            }
        }

        if animated {
            UIView.animate(withDuration: SearchBarConstants.animationDuration) {
                applyLayout()
            }
        } else {
            applyLayout()
        }

        searchBarView.resignFirstResponder()
    }

    func handleViewModeState(_ title: String, _ searchBarContent: String, _ animated: Bool) {
        searchBarView.resignFirstResponder()
        searchBarView.setShowsCancelButton(false, animated: animated)
        searchBarView.text = searchBarContent
        Task {
            let dohEnabled = await FeatureManager.shared.boolValue(of: .dnsOverHTTPSAvailable)
            dohStateIcon.text = "\(dohEnabled ? "DoH" : "")"
            siteNameLabel.text = title
            prepareForViewMode(animated: animated, animateSecurityView: dohEnabled)
        }
    }
}

fileprivate extension Selector {
    static let siteNameTap = #selector(SearchBarLegacyView.handleSiteNameTap(_:))
}
