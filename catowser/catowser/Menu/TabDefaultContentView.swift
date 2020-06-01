//
//  TabDefaultContentView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 6/1/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

#if canImport(SwiftUI)
import SwiftUI
#endif

@available(iOS 13.0, *)
struct TabDefaultContentView: View {
    let model: TabDefaultContentModel
    
    var body: some View {
        List(model.dataSource) { contentValue in
            if contentValue == self.model.selected {
                Text(contentValue.description)
                    .font(Font.headline)
                    .onTapGesture {
                        self.model.onPop(contentValue)
                }
            } else {
                Text(contentValue.description)
                    .onTapGesture {
                        self.model.onPop(contentValue)
                }
            }
        }
        .navigationBarTitle(Text(verbatim: model.viewTitle))
    }
}

#if DEBUG
// swiftlint:disable type_name
@available(iOS 13.0, *)
struct TabDefaultContentView_Previews: PreviewProvider {
    static var previews: some View {
        let model: TabDefaultContentModel = .init { (_) in
            //
        }
        return TabDefaultContentView(model: model)
    }
}
#endif
