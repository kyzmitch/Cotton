//
//  TabAddPositionsViewPreview.swift
//  catowser
//
//  Created by Andrei Ermoshin on 5/30/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import CoreBrowser
#if canImport(SwiftUI)
import SwiftUI
#endif

#if DEBUG
// swiftlint:disable type_name
struct TabAddPositionsView_Previews: PreviewProvider {
    static var previews: some View {
        let model: TabAddPositionsModel = .init { (_) in
            // 
        }
        return BaseMenuView<AddedTabPosition>(model: model)
    }
}
#endif
