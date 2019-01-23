//
//  SearchBarBaseViewController.swift
//  catowser
//
//  Created by admin on 19/02/2018.
//  Copyright © 2018 andreiermoshin. All rights reserved.
//

import UIKit

final class SearchBarBaseViewController<SC: SearchClient>: BaseViewController, UISearchBarDelegate {

    let searchBarView: UISearchBar
    private let suggestionsClient: SC
    
    init(_ searchSuggestionsClient: SC, _ searchBarDelegate: UISearchBarDelegate) {
        suggestionsClient = searchSuggestionsClient
        searchBarView = UISearchBar(frame: CGRect.zero)
        super.init(nibName: nil, bundle: nil)
        searchBarView.delegate = searchBarDelegate
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView()

        view.addSubview(searchBarView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ThemeProvider.shared.setup(searchBarView)
        searchBarView.placeholder = NSLocalizedString("placeholder_searchbar", comment: "The text which is displayed when search bar is empty")

        searchBarView.snp.makeConstraints { (maker) in
            maker.top.equalTo(0)
            maker.leading.equalTo(0)
            maker.trailing.equalTo(0)
            maker.bottom.equalTo(0)
        }
    }
}

private extension UIImage {
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }

    func withRoundCorners(_ cornerRadius: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let rect = CGRect(origin: CGPoint.zero, size: size)
        let context = UIGraphicsGetCurrentContext()
        let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)

        context?.beginPath()
        context?.addPath(path.cgPath)
        context?.closePath()
        context?.clip()

        draw(at: CGPoint.zero)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();

        return image;
    }

}
