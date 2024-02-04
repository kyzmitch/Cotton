//
//  AlertPresenter.swift
//  catowser
//
//  Created by Andrei Ermoshin on 5/2/20.
//  Copyright © 2020 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import UIKit

final class AlertPresenter {
    static func present(on presenter: UIViewController,
                        message: String? = nil,
                        title: String? = NSLocalizedString("Error", comment: ""),
                        style: UIAlertController.Style = .alert,
                        actions: [UIAlertAction]? = [.defaultAction()]) {

        let controller: UIAlertController = .build(message: message,
                                                   title: title,
                                                   style: style,
                                                   actions: actions)

        presenter.present(controller, animated: true)
    }
}

extension UIAlertController {
    class func build(message: String? = nil,
                     title: String? = NSLocalizedString("Error", comment: ""),
                     style: UIAlertController.Style = .alert,
                     actions: [UIAlertAction]? = [.defaultAction()]) -> UIAlertController {

        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: style)

        for action in actions ?? [] {
            alert.addAction(action)
        }

        return alert
    }
}

extension UIAlertAction {
    typealias ActionHandler = (UIAlertAction) -> Void

    class func defaultAction(_ title: String? = NSLocalizedString("OK", comment: ""),
                             handler: ActionHandler? = nil) -> UIAlertAction {
        return UIAlertAction(title: title, style: .default, handler: handler)
    }

    class func destructiveAction(_ title: String?, handler: ActionHandler? = nil) -> UIAlertAction {
        return UIAlertAction(title: title, style: .destructive, handler: handler)
    }
}
