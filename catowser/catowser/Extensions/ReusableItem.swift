//
//  ReusableItem.swift
//  catowser
//
//  Created by Andrei Ermoshin on 23/01/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import UIKit

// swiftlint:disable force_cast

public protocol ReusableItem {
    static var reuseID: String { get }
}

public extension ReusableItem {
    /// By default, use the name of the class as String for its reuseID
    public static var reuseID: String {
        return String(describing: self)
    }
}

public extension UICollectionView {
    func dequeueCell<Cell: UICollectionViewCell>(at indexPath: IndexPath, type: Cell.Type) -> Cell where Cell: ReusableItem {
        return dequeueReusableCell(withReuseIdentifier: Cell.reuseID, for: indexPath) as! Cell
    }

    func dequeueSupplementaryView<View: UICollectionReusableView>(at indexPath: IndexPath, ofKind kind: String, type: View.Type) -> View
        where View: ReusableItem {
            return dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: View.reuseID, for: indexPath) as! View
    }

    func register<Cell: UICollectionViewCell>(_ type: Cell.Type) where Cell: ReusableItem {
        register(type, forCellWithReuseIdentifier: Cell.reuseID)
    }

    func registerNib<Cell: UICollectionViewCell>(with cellType: Cell.Type) where Cell: ReusableItem {
        let nib = UINib(nibName: Cell.reuseID, bundle: Bundle(for: cellType))
        register(nib, forCellWithReuseIdentifier: Cell.reuseID)
    }

    func registerSupplementaryView<View: UICollectionReusableView>(_ type: View.Type, ofKind kind: String) where View: ReusableItem {
        register(type, forSupplementaryViewOfKind: kind, withReuseIdentifier: View.reuseID)
    }
}

public extension UITableView {
    func dequeueCell<Cell: UITableViewCell>(for indexPath: IndexPath, type: Cell.Type) -> Cell where Cell: ReusableItem {
        return dequeueReusableCell(withIdentifier: Cell.reuseID, for: indexPath) as! Cell
    }

    func register<Cell: UITableViewCell>(_ type: Cell.Type) where Cell: ReusableItem {
        register(Cell.self, forCellReuseIdentifier: Cell.reuseID)
    }

    func registerNib<Cell: UITableViewCell>(with cellType: Cell.Type) where Cell: ReusableItem {
        let nib = UINib(nibName: Cell.reuseID, bundle: Bundle(for: cellType))
        register(nib, forCellReuseIdentifier: Cell.reuseID)
    }
}
