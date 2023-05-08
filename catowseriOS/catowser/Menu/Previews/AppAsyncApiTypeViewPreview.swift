//
//  AppAsyncApiTypeViewPreview.swift
//  catowser
//
//  Created by Andrey Ermoshin on 15.02.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import FeaturesFlagsKit
import SwiftUI

#if DEBUG
// swiftlint:disable type_name
struct AppAsyncApiTypeView_Previews: PreviewProvider {
    static var previews: some View {
        let model: AppAsyncApiTypeModel = .init { (_) in
            //
        }
        return BaseMenuView<AsyncApiType>(model: model)
    }
}
#endif
