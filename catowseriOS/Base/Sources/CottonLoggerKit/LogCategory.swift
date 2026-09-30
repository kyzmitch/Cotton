public enum LogCategory: Sendable, Equatable {
    case networking
    case plugins
    case restKit
    case tabs
    case search
    case viewModels
    case featureFlags
    case webView
    case ui
    case downloads
    case coordinator
    case general
    case custom(String)

    var osLogCategory: String {
        switch self {
        case .networking:
            return "networking"
        case .plugins:
            return "plugins"
        case .restKit:
            return "restKit"
        case .tabs:
            return "tabs"
        case .search:
            return "search"
        case .viewModels:
            return "viewModels"
        case .featureFlags:
            return "featureFlags"
        case .webView:
            return "webView"
        case .ui:
            return "ui"
        case .downloads:
            return "downloads"
        case .coordinator:
            return "coordinator"
        case .general:
            return "general"
        case .custom(let value):
            return value
        }
    }
}
