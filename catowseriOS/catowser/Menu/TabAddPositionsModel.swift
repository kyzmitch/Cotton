//
//  TabAddPositionsModel.swift
//  catowser
//
//  Created by Andrei Ermoshin on 5/31/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation
import CoreBrowser

typealias TabAddPositionsModel = BaseListModelImpl<AddedTabPosition>

extension BaseListModelImpl where EnumDataSourceType == AddedTabPosition {
    init(_ completion: @escaping PopClosure) {
        self.init(NSLocalizedString("ttl_tab_positions", comment: ""),
                  completion)
    }
}

/// Declare string representation for CoreBrowser enum
/// in host app to use localized strings.
extension AddedTabPosition: CustomStringConvertible {
    public var description: String {
        let key: String
        
        switch self {
        case .listEnd:
            key = "txt_tab_add_list_end"
        case .afterSelected:
            key = "txt_tab_add_after_selected"
        }
        return NSLocalizedString(key, comment: "")
    }
}

extension AddedTabPosition: Identifiable {
    public var id: RawValue {
        return self.rawValue
    }
    
    // swiftlint:disable:next type_name
    public typealias ID = RawValue
}