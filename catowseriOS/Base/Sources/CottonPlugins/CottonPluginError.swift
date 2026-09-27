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
    case jsFileNotFound(fileName: String)
    case parseError
    case emptyHtml
    case noVideoTags
    case parseHost
    case notExpectedKey
}

extension CottonPluginError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .zombiError:
            return "Plugin handler is no longer available"
        case .nilJSEvaluationResult:
            return "JavaScript evaluation returned no result"
        case .jsEvaluationIsNotString:
            return "JavaScript evaluation result is not a string"
        case .jsEvaluationIsNotURL:
            return "JavaScript evaluation result is not a URL"
        case .jsFileNotFound(let fileName):
            return "JavaScript plugin file not found: \(fileName).js"
        case .parseError:
            return "Failed to parse plugin HTML content"
        case .emptyHtml:
            return "Plugin HTML content is empty"
        case .noVideoTags:
            return "No video tags found in plugin HTML"
        case .parseHost:
            return "Failed to parse host from plugin message"
        case .notExpectedKey:
            return "Unexpected key in plugin JSON payload"
        }
    }
}
