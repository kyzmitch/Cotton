//
//  LinksBadgeView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 24/03/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import UIKit
import CoreBrowser

final class LinksBadgeView: UICollectionViewCell, ReusableItem {
    @IBOutlet weak var badgeLabel: UILabel!
    @IBOutlet weak var tagTypeLabel: UILabel!

    override func layoutSubviews() {
        super.layoutSubviews()

        badgeLabel.layer.cornerRadius = badgeLabel.bounds.size.height / 2
        tagTypeLabel.layer.cornerRadius = tagTypeLabel.bounds.size.height / 2
    }
}
