//
//  SiteCollectionViewCell.swift
//  catowser
//
//  Created by Andrei Ermoshin on 06/05/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import UIKit
import CoreBrowser

final class SiteCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
}

extension SiteCollectionViewCell: ReusableItem {}
