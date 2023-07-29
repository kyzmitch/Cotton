//
//  SearchViewContextImpl.swift
//  catowser
//
//  Created by Andrei Ermoshin on 11/4/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import CottonData
import CoreBrowser
import FeaturesFlagsKit

struct SearchViewContextImpl: SearchViewContext {
    var knownDomainsStorage: KnownDomainsSource {
        InMemoryDomainSearchProvider.shared
    }
    
    var appAsyncApiTypeValue: AsyncApiType {
        get async {
            await FeatureManager.shared.appAsyncApiTypeValue()
        }
    }
}
