//
//  BaseListModelImpl.swift
//  catowser
//
//  Created by Andrey Ermoshin on 19.02.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation

struct BaseListModelImpl<SourceType: CaseIterable>: BaseListModel {
    typealias EnumDataSourceType = SourceType
    
    let dataSource: EnumDataSourceType.AllCases = EnumDataSourceType.allCases
    
    let viewTitle: String
    
    let onPop: PopClosure
    
    let selected: EnumDataSourceType
}
