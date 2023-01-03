//
//  SearchBarLegacyView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 12/15/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import UIKit
import CoreBrowser
import FeaturesFlagsKit

/// The sate of search bar
enum SearchBarState {
    /// initial state for new blank tab
    case blankSearch
    /// keyboard and `cancel` button are visible
    case startSearch
    /// keyboard is hidden and old text is visible
    case cancelTapped
    /// when keyboard and all buttons are not displayed
    case viewMode(_ title: String, _ searchAddressContent: String, _ animated: Bool)
}

final class SearchBarLegacyView: UIView {
    /// Search bar view delegate
    weak var delegate: UISearchBarDelegate? {
        didSet {
            searchBarView.delegate = delegate
        }
    }
    
    // MARK: - state properties
    
    var state: SearchBarState = .blankSearch {
        didSet {
            onStateChange(state)
        }
    }
    
    /// To remember previously entered search query
    private var searchBarContent: String?
    
    // MARK: - initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(searchBarView)
        addSubview(siteNameLabel)
        siteNameLabel.addSubview(dohStateIcon)
        
        siteNameLabel.alpha = 0

        searchBarView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        searchBarView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        searchBarView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        if frame.height > 0 {
            // SwiftUI layout fix because it can't determine the search bar height
            searchBarView.heightAnchor.constraint(equalToConstant: frame.height).isActive = true
        } else {
            searchBarView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }

        siteNameLabel.topAnchor.constraint(equalTo: searchBarView.topAnchor).isActive = true
        siteNameLabel.bottomAnchor.constraint(equalTo: searchBarView.bottomAnchor).isActive = true
        siteNameLabel.widthAnchor.constraint(equalTo: searchBarView.widthAnchor).isActive = true
        hiddenLabelConstraint.isActive = true
        
        dohStateIcon.leadingAnchor.constraint(equalTo: siteNameLabel.leadingAnchor).isActive = true
        dohStateIcon.topAnchor.constraint(equalTo: siteNameLabel.topAnchor).isActive = true
        dohStateIcon.bottomAnchor.constraint(equalTo: siteNameLabel.bottomAnchor).isActive = true
        dohStateIcon.widthAnchor.constraint(equalTo: dohStateIcon.heightAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        // Not sure if this is the right place to start layout
        // maybe init is better or it could be a separate state
        
        siteNameLabel.addGestureRecognizer(siteNameTapGesture)
    }
    
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
    
    private lazy var hiddenLabelConstraint: NSLayoutConstraint = {
        return siteNameLabel.trailingAnchor.constraint(equalTo: leadingAnchor, constant: 0)
    }()

    private lazy var showedLabelConstraint: NSLayoutConstraint = {
        return siteNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0)
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
        case .blankSearch:
            searchBarContent = nil
            searchBarView.text = nil
            siteNameLabel.text = .placeholderText
            searchBarView.setShowsCancelButton(false, animated: false)
            searchBarView.resignFirstResponder()
            // for blank mode it is better to hide label and
            // make search bar frontmost right away
            prepareForEditMode()
        case .startSearch:
            searchBarView.setShowsCancelButton(true, animated: true)
            guard searchBarView.text != nil else {
                break
            }
            // need somehow select all text in search bar view
            prepareForEditMode()
        case .cancelTapped:
            searchBarView.setShowsCancelButton(false, animated: true)
            searchBarView.resignFirstResponder()

            guard searchBarView.text != nil else {
                break
            }

            let dohEnabled = FeatureManager.boolValue(of: .dnsOverHTTPSAvailable)
            dohStateIcon.text = "\(dohEnabled ? "DoH" : "")"
            prepareForViewMode(animated: true, animateSecurityView: dohEnabled)
            // even if search bar now is not visible and
            // it is under label, need to revert text content in it
            searchBarView.text = self.searchBarContent
        case .viewMode(let title, let searchBarContent, let animated):
            searchBarView.setShowsCancelButton(false, animated: animated)
            searchBarView.text = searchBarContent
            let dohEnabled = FeatureManager.boolValue(of: .dnsOverHTTPSAvailable)
            dohStateIcon.text = "\(dohEnabled ? "DoH" : "")"
            siteNameLabel.text = title
            prepareForViewMode(animated: animated, animateSecurityView: dohEnabled)

            // remember search query in case if it will be edited
            self.searchBarContent = searchBarContent
        }
    }
    
    func prepareForEditMode(and showKeyboard: Bool = false) {
        showedLabelConstraint.isActive = false
        hiddenLabelConstraint.isActive = true

        if showKeyboard {
            searchBarView.becomeFirstResponder()
        }
        siteNameLabel.alpha = 0
        dohStateIcon.alpha = 0
        
        UIView.animate(withDuration: 0.3) {
            self.siteNameLabel.layoutIfNeeded()
            self.searchBarView.alpha = 1
        }
    }
    
    func prepareForViewMode(animated: Bool = true, animateSecurityView: Bool = false) {
        // Order of disabling/enabling is important
        // to not to cause errors in layout calculation.
        // First need to disable and after that enable new one.
        hiddenLabelConstraint.isActive = false
        showedLabelConstraint.isActive = true
        
        func applyLayout() {
            siteNameLabel.layoutIfNeeded()
            searchBarView.alpha = 0
            siteNameLabel.alpha = 1
            if animateSecurityView {
                dohStateIcon.alpha = 1
            }
        }
        
        if animated {
            UIView.animate(withDuration: 0.3) {
                applyLayout()
            }
        } else {
            applyLayout()
        }
        
        searchBarView.resignFirstResponder()
    }
}

fileprivate extension Selector {
    static let siteNameTap = #selector(SearchBarLegacyView.handleSiteNameTap(_:))
}

private extension String {
    static let placeholderText: String = NSLocalizedString("placeholder_searchbar",
                                                           comment: "when search bar is empty")
}
