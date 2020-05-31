//
//  TabAddPositionsView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 5/30/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

#if canImport(SwiftUI)
import SwiftUI
#endif

typealias DismissClosure = () -> Void

@available(iOS 13.0, *)
struct TabAddPositionsView: View {
    let model: TabAddPositionsModel
    
    var body: some View {
        List(model.dataSource) { position in
            if position == self.model.selected {
                Text(position.description)
                    .font(Font.headline)
                    .onTapGesture {
                        self.model.onPop(position)
                }
            } else {
                Text(position.description)
                    .onTapGesture {
                        self.model.onPop(position)
                }
            }
        }
        .navigationBarTitle(Text(verbatim: model.viewTitle))
    }
}

#if DEBUG
// swiftlint:disable type_name
@available(iOS 13.0, *)
struct TabAddPositionsView_Previews: PreviewProvider {
    static var previews: some View {
        let model: TabAddPositionsModel = .init { (_) in
            // 
        }
        return TabAddPositionsView(model: model)
    }
}
#endif
