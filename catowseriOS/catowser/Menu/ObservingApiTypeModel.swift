//
//  ObservingApiTypeModel.swift
//  catowser
//
//  Created by Andrey Ermoshin on 15.02.2022.
//  Copyright © 2022 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import CoreBrowser
import Foundation
import FeaturesFlagsKit

typealias ObservingApiTypeModel = BaseListViewModelImpl<ObservingApiType>

extension BaseListViewModelImpl where EnumDataSourceType == ObservingApiType {
    init(
        _ selected: EnumDataSourceType?,
        _ completion: @escaping PopClosure
    ) {
        self.init(
            NSLocalizedString(.observingApiTypeTxt, comment: ""),
            completion,
            selected
        )
    }
}

extension ObservingApiType: @retroactive CustomStringConvertible {
    public var description: String {
        let key: String

        switch self {
        case .observerDesignPattern:
            key = "txt_app_observing_api_system"
        case .systemObservation:
            key = "txt_app_observing_api_design_pattern"
        }
        return NSLocalizedString(key, comment: "")
    }
}

extension ObservingApiType: @retroactive Identifiable {
    public var id: RawValue {
        return self.rawValue
    }

    public typealias ID = RawValue
}
