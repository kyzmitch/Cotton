//
//  WebSearchSettingsModel.swift
//  BrowserNetworking
//
//  Created by Andrey Ermoshin on 19.02.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation

typealias WebSearchSettingsModel = BaseListModelImpl<WebAutoCompletionSource>

extension BaseListModelImpl where EnumDataSourceType == WebAutoCompletionSource {
    init(_ completion: @escaping PopClosure) {
        self.init(FeatureManager.webSearchAutoCompleteValue(),
                  NSLocalizedString("ttl_web_search_auto_complete_source", comment: ""),
                  completion)
    }
}

extension WebAutoCompletionSource: CustomStringConvertible {
    public var description: String {
        let key: String
        
        // Not need to localize the names
        switch self {
        case .duckduckgo:
            key = "DuckDuckGo"
        case .google:
            key = "Google"
        }
        return key
    }
}

extension WebAutoCompletionSource: Identifiable {
    public var id: RawValue {
        return self.rawValue
    }
    
    // swiftlint:disable:next type_name
    public typealias ID = RawValue
}
