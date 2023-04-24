//
//  TopSitesViewV2.swift
//  catowser
//
//  Created by Andrei Ermoshin on 4/24/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import SwiftUI
import CottonCoreBaseKit

@available(iOS 14.0, *)
struct TopSitesViewV2: View {
    private let vm: TopSitesViewModel
    
    init(_ vm: TopSitesViewModel) {
        self.vm = vm
    }
    
    /// Number of items will be display in row
    private let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: ImageViewSizes.spacing) {
                ForEach(vm.topSites) { site in
                    TitledImageView(site.faviconURL, site.favicon(), site.title)
                }
            }
        }
    }
}

struct TitledImageView: View {
    private let url: URL?
    private let hqImage: UIImage?
    private let title: String
    
    private let cellWidth = ImageViewSizes.imageHeight
    
    init(_ url: URL?, _ hqImage: UIImage?, _ title: String) {
        self.url = url
        self.hqImage = hqImage
        self.title = title
    }
    
    var body: some View {
        VStack {
            AsyncImage(url: url) { image in
                image.resizable(resizingMode: .stretch)
            } placeholder: {
                if let cachedImage = hqImage {
                    Image(uiImage: cachedImage)
                } else {
                    Color.gray
                }
            }
                .frame(width: cellWidth, height: cellWidth)
                .cornerRadius(3)
            Text(verbatim: title)
                .font(.system(size: 10))
                .frame(maxWidth: cellWidth, maxHeight: ImageViewSizes.titleHeight)
        }
    }
}
