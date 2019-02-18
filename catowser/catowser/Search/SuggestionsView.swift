//
//  SuggestionsView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 2/18/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import UIKit

fileprivate protocol SuggestionCellDelegate: AnyObject {
    func suggestionCell(_ suggestionCell: SuggestionCell, didSelectSuggestion suggestion: String)
    func suggestionCell(_ suggestionCell: SuggestionCell, didLongPressSuggestion suggestion: String)
}

/**
 * Cell that wraps a list of search suggestion buttons.
 */
fileprivate class SuggestionCell: UITableViewCell {
    weak var delegate: SuggestionCellDelegate?
    let container = UIView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        isAccessibilityElement = false
        accessibilityLabel = nil
        layoutMargins = .zero
        separatorInset = .zero
        selectionStyle = .none
        
        container.backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        backgroundColor = UIColor.clear
        contentView.addSubview(container)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var suggestions: [String] = [] {
        didSet {
            for view in container.subviews {
                view.removeFromSuperview()
            }
            
            for suggestion in suggestions {
                let button = SuggestionButton()
                button.setTitle(suggestion, for: [])
                button.addTarget(self, action: #selector(didSelectSuggestion), for: .touchUpInside)
                button.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(didLongPressSuggestion)))
                
                // If this is the first image, add the search icon.
                if container.subviews.isEmpty {
                    let image = UIImage(named: SearchViewControllerUX.SearchImage)
                    button.setImage(image, for: [])
                    if UIApplication.shared.userInterfaceLayoutDirection == .leftToRight {
                        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
                    } else {
                        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
                    }
                }
                
                container.addSubview(button)
            }
            
            setNeedsLayout()
        }
    }
    
    @objc
    func didSelectSuggestion(_ sender: UIButton) {
        delegate?.suggestionCell(self, didSelectSuggestion: sender.titleLabel!.text!)
    }
    
    @objc
    func didLongPressSuggestion(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            if let button = recognizer.view as! UIButton? {
                delegate?.suggestionCell(self, didLongPressSuggestion: button.titleLabel!.text!)
            }
        }
    }
    
    fileprivate override func layoutSubviews() {
        super.layoutSubviews()
        
        // The left bounds of the suggestions, aligned with where text would be displayed.
        let textLeft: CGFloat = 61
        
        // The maximum width of the container, after which suggestions will wrap to the next line.
        let maxWidth = contentView.frame.width
        
        let imageSize = CGFloat(SearchViewControllerUX.FaviconSize)
        
        // The height of the suggestions container (minus margins), used to determine the frame.
        // We set it to imageSize.height as a minimum since we don't want the cell to be shorter than the icon
        var height: CGFloat = imageSize
        
        var currentLeft = textLeft
        var currentTop = SearchViewControllerUX.SuggestionCellVerticalPadding
        var currentRow = 0
        
        for view in container.subviews {
            let button = view as! UIButton
            var buttonSize = button.intrinsicContentSize
            
            // Update our base frame height by the max size of either the image or the button so we never
            // make the cell smaller than any of the two
            if height == imageSize {
                height = max(buttonSize.height, imageSize)
            }
            
            var width = currentLeft + buttonSize.width + SearchViewControllerUX.SuggestionMargin
            if width > maxWidth {
                // Only move to the next row if there's already a suggestion on this row.
                // Otherwise, the suggestion is too big to fit and will be resized below.
                if currentLeft > textLeft {
                    currentRow += 1
                    if currentRow >= SearchViewControllerUX.SuggestionCellMaxRows {
                        // Don't draw this button if it doesn't fit on the row.
                        button.frame = .zero
                        continue
                    }
                    
                    currentLeft = textLeft
                    currentTop += buttonSize.height + SearchViewControllerUX.SuggestionMargin
                    height += buttonSize.height + SearchViewControllerUX.SuggestionMargin
                    width = currentLeft + buttonSize.width + SearchViewControllerUX.SuggestionMargin
                }
                
                // If the suggestion is too wide to fit on its own row, shrink it.
                if width > maxWidth {
                    buttonSize.width = maxWidth - currentLeft - SearchViewControllerUX.SuggestionMargin
                }
            }
            
            button.frame = CGRect(x: currentLeft, y: currentTop, width: buttonSize.width, height: buttonSize.height)
            currentLeft += buttonSize.width + SearchViewControllerUX.SuggestionMargin
        }
        
        frame.size.height = height + 2 * SearchViewControllerUX.SuggestionCellVerticalPadding
        contentView.frame = bounds
        container.frame = bounds
        
        let imageX = (textLeft - imageSize) / 2
        let imageY = (frame.size.height - imageSize) / 2
        imageView!.frame = CGRect(x: imageX, y: imageY, width: imageSize, height: imageSize)
    }
}

/**
 * Rounded search suggestion button that highlights when selected.
 */
fileprivate class SuggestionButton: InsetButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setTitleColor(UIColor.theme.homePanel.searchSuggestionPillForeground, for: [])
        setTitleColor(UIColor.Photon.White100, for: .highlighted)
        titleLabel?.font = DynamicFontHelper.defaultHelper.DefaultMediumFont
        backgroundColor = SearchViewControllerUX.SuggestionBackgroundColor
        layer.borderColor = SearchViewControllerUX.SuggestionBorderColor.cgColor
        layer.borderWidth = SearchViewControllerUX.SuggestionBorderWidth
        layer.cornerRadius = SearchViewControllerUX.SuggestionCornerRadius
        contentEdgeInsets = SearchViewControllerUX.SuggestionInsets
        
        accessibilityHint = NSLocalizedString("Searches for the suggestion", comment: "Accessibility hint describing the action performed when a search suggestion is clicked")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor.theme.general.highlightBlue : SearchViewControllerUX.SuggestionBackgroundColor
        }
    }
}
