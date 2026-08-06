//
//  WebViewModelStateError.swift
//  catowser
//
//  Created by Andrey Ermoshin on 29.12.2024.
//  Copyright © 2024 Cotton (Catowser). All rights reserved.
//

import Foundation

extension WebViewModelState {
    public enum Error: LocalizedError {
        case unexpectedStateForAction(WebViewModelState, WebViewAction)
        case notImplemented

        public var errorDescription: String? {
            switch self {
            case .unexpectedStateForAction(let state, let action):
                "Unexpected state \"\(state.description)\" for action \"\(action.description)\""
            case .notImplemented:
                "Not implemented"
            }
        }
    }
}
