//
//  TabDefaultContentModel.swift
//  catowser
//
//  Created by Andrei Ermoshin on 6/1/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import CoreBrowser

typealias TabDefaultContentModel = BaseListModelImpl<TabContentDefaultState>

extension BaseListModelImpl where EnumDataSourceType == TabContentDefaultState {
    init(_ completion: @escaping PopClosure) {
        self.init(FeatureManager.tabDefaultContentValue(),
                  NSLocalizedString("ttl_tab_default_content", comment: ""),
                  completion)
    }
}

extension TabContentDefaultState: Identifiable {
    public var id: RawValue {
        return self.rawValue
    }
    
    // swiftlint:disable:next type_name
    public typealias ID = RawValue
}
