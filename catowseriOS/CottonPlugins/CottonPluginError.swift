//
//  CottonPluginError.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 5/30/22.
//  Copyright © 2022 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import Foundation

enum CottonPluginError: Error {
    case zombiError
    case nilJSEvaluationResult
    case jsEvaluationIsNotString
    case jsEvaluationIsNotURL
    case parseError
    case emptyHtml
    case noVideoTags
    case parseHost
    case notExpectedKey
}
