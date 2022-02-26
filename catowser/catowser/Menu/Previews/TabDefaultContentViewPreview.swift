//
//  TabDefaultContentViewPreview.swift
//  catowser
//
//  Created by Andrei Ermoshin on 6/1/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import CoreBrowser
#if canImport(SwiftUI)
import SwiftUI
#endif

#if DEBUG
// swiftlint:disable type_name
@available(iOS 13.0, *)
struct TabDefaultContentView_Previews: PreviewProvider {
    static var previews: some View {
        let model: TabDefaultContentModel = .init { (_) in
            //
        }
        return BaseMenuView<TabContentDefaultState>(model: model)
    }
}
#endif