//
//  BaseMenuView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 2/21/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import SwiftUI
import FeaturesFlagsKit

typealias SwiftUIValueRequirements = Hashable & Identifiable & CustomStringConvertible

struct BaseMenuView<SourceType: FullEnumTypeConstraints & SwiftUIValueRequirements>: View
where SourceType.RawValue == Int, SourceType.AllCases: RandomAccessCollection {
    
    let model: BaseListModelImpl<SourceType>
    
    var body: some View {
        List(model.dataSource) { selectedCase in
            if selectedCase == self.model.selected {
                Text(selectedCase.description)
                    .font(Font.headline)
                    .onTapGesture {
                        self.model.onPop(selectedCase)
                }
            } else {
                Text(selectedCase.description)
                    .onTapGesture {
                        self.model.onPop(selectedCase)
                }
            }
        }
        .navigationBarTitle(Text(verbatim: model.viewTitle))
    }
}
