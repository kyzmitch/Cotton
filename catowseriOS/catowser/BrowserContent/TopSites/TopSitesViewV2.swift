//
//  TopSitesViewV2.swift
//  catowser
//
//  Created by Andrei Ermoshin on 4/24/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import SwiftUI
import CottonCoreBaseKit

@available(iOS 16.0, *)
struct TopSitesViewV2: View {
    private let vm: TopSitesViewModel
    
    init(_ vm: TopSitesViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        Table(vm.topSites) {
            TableColumn("txt_top_site_favicon", content: { site in
                AsyncImage(url: site.faviconURL) { image in
                    image.resizable(resizingMode: .stretch)
                } placeholder: {
                    if let cachedImage = site.favicon() {
                        Image(uiImage: cachedImage)
                    } else {
                        Color.gray
                    }
                }
                    .frame(width: ImageViewSizes.titleHeight * 3, height: ImageViewSizes.titleHeight * 3)
                    .cornerRadius(3)
            })
            TableColumn("txt_top_site_title", value: \.title)
                .width(ideal: ImageViewSizes.titleHeight * 3)
        }
    }
}

struct TitledImageView: View {
    private let url: URL?
    private let hqImage: UIImage?
    private let title: String
    
    init(_ url: URL?, _ hqImage: UIImage?, _ title: String) {
        self.url = url
        self.hqImage = hqImage
        self.title = title
    }
    
    var body: some View {
        let imageH = ImageViewSizes.titleHeight
        AsyncImage(url: url) { image in
            image.resizable(resizingMode: .tile)
        } placeholder: {
            if let cachedImage = hqImage {
                Image(uiImage: cachedImage)
            } else {
                Color.gray
            }
        }
            .frame(width: imageH, height: imageH)
            .cornerRadius(3)
        Text(verbatim: title)
            .frame(width: imageH, height: ImageViewSizes.titleHeight)
    }
}
