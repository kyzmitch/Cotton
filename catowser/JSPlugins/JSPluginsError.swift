//
//  JSPluginsError.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 5/30/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation

enum JSPluginsError: LocalizedError {
    case zombiError
    case nilJSEvaluationResult
    case jsEvaluationIsNotString
    case jsEvaluationIsNotURL
}

struct EvalError: Error {}