//
//  ReloadWithCompletion.swift
//  CoreBrowser
//
//  Created by Andrei Ermoshin on 24/04/2019.
//  Copyright © 2019 Cotton (former Catowser). All rights reserved.
//

import UIKit

protocol ReloadableCollection {
    func reloadData()
    func reloadData(_ closure: @escaping (() -> Void))
}

extension UICollectionView: ReloadableCollection {}

extension UITableView: ReloadableCollection {}

extension ReloadableCollection {
    /// https://stackoverflow.com/a/43162226/483101
    /// Calls reloadsData() on self, and ensures that the given closure is
    /// called after reloadData() has been completed.
    ///
    /// Discussion: reloadData() appears to be asynchronous. i.e. the
    /// reloading actually happens during the next layout pass. So, doing
    /// things like scrolling the collectionView immediately after a
    /// call to reloadData() can cause trouble.
    ///
    /// This method uses CATransaction to schedule the closure.

    public func reloadData(_ closure: @escaping (() -> Void)) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(closure)
        self.reloadData()
        CATransaction.commit()
    }
}
