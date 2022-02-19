//
//  WebSearchSettingsModel.swift
//  BrowserNetworking
//
//  Created by Andrey Ermoshin on 19.02.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation

typealias WebSearchAutoCompletionSelectPopClosure = (WebAutoCompletionSource) -> Void

struct WebSearchSettingsModel {
    let dataSource = WebAutoCompletionSource.allCases
    
    let viewTitle = NSLocalizedString("ttl_web_search_auto_complete_source", comment: "")
    
    let onPop: WebSearchAutoCompletionSelectPopClosure
    
    let selected = FeatureManager.webSearchAutoCompleteValue()
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
