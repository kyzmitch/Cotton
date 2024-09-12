//
//  TabDefaultContentViewPreview.swift
//  catowser
//
//  Created by Andrei Ermoshin on 6/1/20.
//  Copyright © 2020 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import CoreBrowser
#if canImport(SwiftUI)
import SwiftUI
#endif

#if DEBUG
struct TabDefaultContentView_Previews: PreviewProvider {
    static var previews: some View {
        let model: TabDefaultContentModel = .init(nil) { (_) in
            //
        }
        return BaseMenuView<CoreBrowser.Tab.ContentType>(viewModel: model)
    }
}
#endif
