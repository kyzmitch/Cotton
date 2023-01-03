//
//  SearchBarV2View.swift
//  catowser
//
//  Created by Andrey Ermoshin on 10.12.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import SwiftUI

// https://stackoverflow.com/questions/56490963/how-to-display-a-search-bar-with-swiftui

/**
 There are possibly 3 options on how to create a search bar:
 - wrap UIKit's UISearchBar view into some struct which confirms to `UIViewRepresentable`
 - write own implementation as below
 - use iOS 15 `searchable` property on some view
 
 Need to not forget to use ThemeProvider.shared.setup(view)
 for search bar view to make it similar with UIKit version.
 */

struct SearchBarView: View {
    var body: some View {
        _SearchBarLegacyView()
    }
}

private struct _SearchBarLegacyView: UIViewRepresentable {
    func makeUIView(context: Context) -> some UIView {
        let customFrame: CGRect = .init(x: 0, y: 0, width: .greatestFiniteMagnitude, height: .searchViewHeight)
        let uiKitView = SearchBarLegacyView(frame: customFrame)
        return uiKitView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}

struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarView()
    }
}
