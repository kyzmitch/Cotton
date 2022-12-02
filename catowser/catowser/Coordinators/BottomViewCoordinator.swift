//
//  BottomViewCoordinator.swift
//  catowser
//
//  Created by Andrei Ermoshin on 12/2/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import UIKit

final class BottomViewCoordinator: Coordinator {
    let vcFactory: any ViewControllerFactory
    var startedCoordinator: Coordinator?
    weak var parent: CoordinatorOwner?
    var startedVC: AnyViewController?
    weak var presenterVC: AnyViewController?
    
    var tabletTopAnchor: NSLayoutYAxisAnchor {
        underLinkTagsView.topAnchor
    }
    
    var tabletBottomAnchor: NSLayoutYAxisAnchor {
        underLinkTagsView.bottomAnchor
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
        case .viewDidLoad(let topAnchor, _):
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
        guard let controllerView = presenterVC?.controllerView else {
            return
        }
        if isPad {
            underLinkTagsView.leadingAnchor.constraint(equalTo: controllerView.leadingAnchor).isActive = true
            underLinkTagsView.trailingAnchor.constraint(equalTo: controllerView.trailingAnchor).isActive = true
            let dummyViewHeight: CGFloat = .safeAreaBottomMargin
            let linksHConstraint = underLinkTagsView.heightAnchor.constraint(equalToConstant: dummyViewHeight)
            underLinksViewHeightConstraint = linksHConstraint
            underLinksViewHeightConstraint?.isActive = true
        } else {
            guard let anchor = topAnchor else {
                return
            }
            underToolbarView.topAnchor.constraint(equalTo: anchor).isActive = true
            underToolbarView.leadingAnchor.constraint(equalTo: controllerView.leadingAnchor).isActive = true
            underToolbarView.trailingAnchor.constraint(equalTo: controllerView.trailingAnchor).isActive = true
            underToolbarView.bottomAnchor.constraint(equalTo: controllerView.bottomAnchor).isActive = true
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
