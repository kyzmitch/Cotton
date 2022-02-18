//
//  AppAsyncApiTypeModel.swift
//  catowser
//
//  Created by Andrey Ermoshin on 15.02.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import CoreBrowser

typealias AsyncApiSelectionPopClosure = (AsyncApiType) -> Void

struct AppAsyncApiTypeModel {
    let dataSource = AsyncApiType.allCases
    
    let viewTitle = NSLocalizedString("ttl_app_async_method", comment: "")
    
    let onPop: AsyncApiSelectionPopClosure
    
    let selected: AsyncApiType = FeatureManager.appAsyncApiTypeValue()
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
    
    // swiftlint:disable:next type_name
    public typealias ID = RawValue
}
