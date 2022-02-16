//
//  AppAsyncApiTypeView.swift
//  catowser
//
//  Created by Andrey Ermoshin on 15.02.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

#if canImport(SwiftUI)
import SwiftUI
#endif

// TODO: create base view with Generic type to represent the model type for (AppAsyncApiTypeView, TabDefaultContentView, TabAddPositionsView)

@available(iOS 13.0, *)
struct AppAsyncApiTypeView: View {
    let model: AppAsyncApiTypeModel
    
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
struct AppAsyncApiTypeView_Previews: PreviewProvider {
    static var previews: some View {
        let model: AppAsyncApiTypeModel = .init { (_) in
            //
        }
        return AppAsyncApiTypeView(model: model)
    }
}
#endif
