//
//  BottomViewCoordinator.swift
//  catowser
//
//  Created by Andrei Ermoshin on 12/2/22.
//  Copyright © 2022 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import UIKit

final class BottomViewCoordinator: Coordinator {
    let vcFactory: any ViewControllerFactory
    var startedCoordinator: Coordinator?
    weak var parent: CoordinatorOwner?
    var startedVC: AnyViewController?
    weak var presenterVC: AnyViewController?
    var navigationStack: UINavigationController?
    
    /// Overwritten getter because there is no view controller which holds started view
    var startedView: UIView? {
        if isPad {
            return underLinkTagsView
        } else {
            return underToolbarView
        }
    }
    
    private lazy var underLinkTagsView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        ThemeProvider.shared.setupUnderLinkTags(v)
        return v
    }()
    
    /// View to make color under toolbar is the same on iPhone x without home button
    private lazy var underToolbarView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        ThemeProvider.shared.setupUnderToolbar(v)
        return v
    }()
    
    private var underLinksViewHeightConstraint: NSLayoutConstraint?
    
    /// Convinience property for specific view bounds
    var underToolbarViewBounds: CGRect? {
        underToolbarView.bounds
    }
    
    init(_ vcFactory: any ViewControllerFactory,
         _ presenter: AnyViewController) {
        self.vcFactory = vcFactory
        self.presenterVC = presenter
    }
    
    func start() {
        if isPad {
            presenterVC?.controllerView.addSubview(underLinkTagsView)
        } else {
            // Need to not add it if it is not iPhone without home button
            presenterVC?.controllerView.addSubview(underToolbarView)
        }
    }
}

enum BottomViewPart: SubviewPart {}

extension BottomViewCoordinator: Layouting {
    typealias SP = BottomViewPart
    
    func insertNext(_ subview: SP) {}
    
    func layout(_ step: OwnLayoutStep) {
        switch step {
        case .viewDidLoad(let topAnchor, _, _):
            viewDidLoad(topAnchor)
        case .viewSafeAreaInsetsDidChange:
            viewSafeAreaInsetsDidChange()
        default:
            break
        }
    }
    
    func layoutNext(_ step: LayoutStep<SP>) {
        
    }
}

private extension BottomViewCoordinator {
    func viewDidLoad(_ topAnchor: NSLayoutYAxisAnchor?) {
        guard let superView = presenterVC?.controllerView else {
            return
        }
        if isPad {
            // Not using top anchor, because there is a constant height of dummy view
            // and it can be overlap web content container,
            // but provided anchor of web content container view MUST be set
            // so that, setting it here
            topAnchor?.constraint(equalTo: superView.bottomAnchor).isActive = true
            
            underLinkTagsView.leadingAnchor.constraint(equalTo: superView.leadingAnchor).isActive = true
            underLinkTagsView.trailingAnchor.constraint(equalTo: superView.trailingAnchor).isActive = true
            let dummyViewHeight: CGFloat = .safeAreaBottomMargin
            let linksHConstraint = underLinkTagsView.heightAnchor.constraint(equalToConstant: dummyViewHeight)
            underLinksViewHeightConstraint = linksHConstraint
            underLinksViewHeightConstraint?.isActive = true
        } else {
            guard let topViewAnchor = topAnchor else {
                return
            }
            underToolbarView.topAnchor.constraint(equalTo: topViewAnchor).isActive = true
            underToolbarView.leadingAnchor.constraint(equalTo: superView.leadingAnchor).isActive = true
            underToolbarView.trailingAnchor.constraint(equalTo: superView.trailingAnchor).isActive = true
            underToolbarView.bottomAnchor.constraint(equalTo: superView.bottomAnchor).isActive = true
        }
    }
    
    func viewSafeAreaInsetsDidChange() {
        guard isPad else {
            return
        }
        guard let controllerView = presenterVC?.controllerView else {
            return
        }
        // only here we can get correct value for safe area inset
        underLinksViewHeightConstraint?.constant = controllerView.safeAreaInsets.bottom
        underLinkTagsView.setNeedsLayout()
        underLinkTagsView.layoutIfNeeded()
    }
}
