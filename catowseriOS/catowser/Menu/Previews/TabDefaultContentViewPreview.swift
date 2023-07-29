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
struct TabDefaultContentView_Previews: PreviewProvider {
    static var previews: some View {
        let model: TabDefaultContentModel = .init(nil) { (_) in
            //
        }
        return BaseMenuView<TabContentDefaultState>(viewModel: model)
    }
}
#endif
