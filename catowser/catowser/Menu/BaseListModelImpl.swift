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
    
    /// Need to improve/re-desing Feature system to initialize it here based on a generic type instead of init usage
    let selected: EnumDataSourceType
    
    init(_ selectedValue: EnumDataSourceType, _ title: String, _ completion: @escaping PopClosure) {
        // TODO: re-design Feature system to initialize it using generic type and without passing the argument
        selected = selectedValue
        viewTitle = title
        onPop = completion
    }
}
