//
//  AppAsyncApiTypeModel.swift
//  catowser
//
//  Created by Andrey Ermoshin on 15.02.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import FeaturesFlagsKit

typealias AppAsyncApiTypeModel = BaseListViewModelImpl<AsyncApiType>

extension BaseListViewModelImpl where EnumDataSourceType == AsyncApiType {
    init( _ selected: EnumDataSourceType?, _ completion: @escaping PopClosure) {
        self.init(NSLocalizedString("ttl_app_async_method", comment: ""),
                  completion,
                  selected)
    }
}

extension AsyncApiType: CustomStringConvertible {
    public var description: String {
        let key: String
        
        switch self {
        case .reactive:
            key = "txt_app_async_api_reactive"
        case .combine:
            key = "txt_app_async_api_combine"
        case .asyncAwait:
            key = "txt_app_async_api_async_await"
        }
        return NSLocalizedString(key, comment: "")
    }
}

extension AsyncApiType: Identifiable {
    public var id: RawValue {
        return self.rawValue
    }
    
    public typealias ID = RawValue
}
