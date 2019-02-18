//
//  WebSearchResultTableViewCell.swift
//  catowser
//
//  Created by Andrey Ermoshin on 24/02/2018.
//  Copyright © 2018 andreiermoshin. All rights reserved.
//

import UIKit

final class WebSearchResultTableViewCell: UITableViewCell {

    private let container = UIView()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        container.backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        backgroundColor = UIColor.clear
        // If you want to go beyond the predefined styles,
        // you can add subviews to the contentView property of the cell.
        // When adding subviews, you are responsible for positioning
        // those views and setting their content yourself.
        contentView.addSubview(container)
        
        container.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        container.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        container.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        container.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
        
        /*
         It seems SnapKit version is still much smaller
         than an NSLayoutAnchor API which could be used since iOS 9
         
         container.snp.makeConstraints { (make) in
            make.leading.equalTo(contentView)
            make.trailing.equalTo(contentView)
            make.top.equalTo(contentView)
            make.bottom.equalTo(contentView)
         }
         */
        
        container.addSubview(titleLabel)
        container.addSubview(iconImageView)
        
        iconImageView.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
        iconImageView.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        iconImageView.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        iconImageView.widthAnchor.constraint(equalTo: container.heightAnchor).isActive = true
        
        titleLabel.leadingAnchor.constraint(equalTo: iconImageView.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        
        titleLabel.firstBaselineAnchor.constraint(equalToSystemSpacingBelow: container.topAnchor, multiplier: 1).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static let cellIdentifier = UIIdentifiers.webSearchResultCellId
}
