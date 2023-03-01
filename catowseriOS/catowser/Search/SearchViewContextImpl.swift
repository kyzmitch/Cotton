//
//  SearchViewContextImpl.swift
//  catowser
//
//  Created by Andrei Ermoshin on 11/4/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import CoreCatowser
import CoreBrowser
import FeaturesFlagsKit

struct SearchViewContextImpl: SearchViewContext {
    var knownDomainsStorage: KnownDomainsSource {
        InMemoryDomainSearchProvider.shared
    }
    
    var appAsyncApiTypeValue: AsyncApiType {
        FeatureManager.appAsyncApiTypeValue()
    }
}
