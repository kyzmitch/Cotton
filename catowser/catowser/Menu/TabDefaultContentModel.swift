//
//  TabDefaultContentModel.swift
//  catowser
//
//  Created by Andrei Ermoshin on 6/1/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import CoreBrowser

typealias TabDefaultContentPopClosure = (TabContentDefaultState) -> Void

struct TabDefaultContentModel {
    let dataSource = TabContentDefaultState.allCases
    
    let viewTitle = NSLocalizedString("ttl_tab_default_content", comment: "")
    
    let onPop: TabDefaultContentPopClosure
    
    let selected: TabContentDefaultState = FeatureManager.tabDefaultContentValue()
}

extension TabContentDefaultState: Identifiable {
    public var id: RawValue {
        return self.rawValue
    }
    
    // swiftlint:disable:next type_name
    public typealias ID = RawValue
}
