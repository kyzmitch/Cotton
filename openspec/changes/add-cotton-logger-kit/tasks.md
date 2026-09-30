## 1. Kit scaffolding in the Base package

- [x] 1.1 Add `CottonLoggerKit` target and library product to `catowseriOS/Base/Package.swift` (no dependencies, `Sources/CottonLoggerKit`)
- [x] 1.2 Create `Sources/CottonLoggerKit/` with `LogLevel` (`debug`, `info`, `warning`, `error`, `fault`) and `LogCategory` (`Sendable` enum: networking, plugins, restKit, tabs, search, viewModels, featureFlags, webView, ui, downloads, coordinator, general + `.custom(String)`)
- [x] 1.3 Implement `CottonLogger` struct (category at init; `debug/info/warning/error/fault` methods with `@autoclosure () -> String` message and `#fileID`/`#function`/`#line` defaults)

## 2. Backend and configuration

- [x] 2.1 Define `public protocol LogBackend: Sendable` with `log(_:category:message:file:function:line:)`
- [x] 2.2 Implement `SystemLogBackend`: `os.Logger` path (`@available` iOS 14/macOS 11, subsystem `com.ae.cotton-browser`, category string mapping, `warning` → default severity) and `os_log` fallback for the iOS 13 floor
- [x] 2.3 Implement `LoggerConfiguration` (minimum level default `.debug` in DEBUG / `.info` otherwise; backend default `SystemLogBackend`) guarded by `NSLock`; level filtering in `CottonLogger` before evaluating the message closure
- [x] 2.4 Add file-scoped convenience statics on `CottonLogger` for common categories (e.g. `.networking`, `.tabs`, `.ui`)

## 3. Kit tests (Swift Testing)

- [x] 3.1 Add `CottonLoggerKitTests` test target to `Base/Package.swift`
- [x] 3.2 Test minimum-level filtering: above-minimum delivered once, below-minimum not delivered and autoclosure not evaluated
- [x] 3.3 Test category routing (init category appears on every record; `.custom` string preserved) and single evaluation of logged messages
- [x] 3.4 Test configuration restore (installed capturing backend is removed after restore)

## 4. Base sources migration (28 sites)

- [x] 4.1 Add `CottonLoggerKit` dependency to `CottonNetworking`, `CottonPlugins`, `CottonRestKit` targets in `Base/Package.swift`
- [x] 4.2 Migrate `CottonNetworking/TransportAdapters/` (AlamofireHTTPAdaptee, AlamofireHTTPRxAdaptee — 3 sites) with `.networking`
- [x] 4.3 Migrate `CottonPlugins` handlers and models (BaseJSHandler, InstagramHandler, JSPluginFactory, JSPluginsProgramImpl, JavaScriptEvaluateble, Data+CatowserExtension, HTMLContentMessage, HTMLVideoTag, HTMLVideoTagsContainer — 23 sites) with `.plugins`
- [x] 4.4 Migrate `CottonRestKit` (RestClient, RestClient+Combine — 2 sites) with `.restKit`
- [x] 4.5 Build Base package and run its tests (`swift build && swift test` in `catowseriOS/Base`)

## 5. Domain sources migration (31 sites)

- [x] 5.1 Add `CottonLoggerKit` product dependency (from Base) to logging Domain targets in `Domain/Package.swift` (CoreBrowser, CottonSearch, CottonTabs, CottonViewModels, FeatureFlagsKit, GenericServiceKit, ViewModelKit)
- [x] 5.2 Migrate `CoreBrowser` (Tab, OpenSearchParser — 3 sites) with `.general`/`.search`
- [x] 5.3 Migrate `CottonSearch/SearchDataService` (1 site, `.search`) and `CottonTabs/TabsDataService` (9 sites, `.tabs`)
- [x] 5.4 Migrate `CottonViewModels` (AllTabsViewModel, SearchBarDelegateImpl, SearchSuggestionsViewState, TabViewModelImpl, TopSitesViewModelImpl, WebViewModelImpl — 14 sites) with `.viewModels`
- [x] 5.5 Migrate `FeatureFlagsKit/LocalFeatureSource`, `GenericServiceKit/GenericConcurrentDataService`, `ViewModelKit/ViewModelConsumer` (4 sites) with matching categories
- [x] 5.6 Build Domain package and run its tests

## 6. Presentation sources migration (2 sites)

- [x] 6.1 Add `CottonLoggerKit` product dependency to logging Presentation targets in `Presentation/Package.swift` (SearchViews, CottonDesignKit)
- [x] 6.2 Migrate `SearchViews/SearchBarLegacyView` (`.ui`, error) and `CottonDesignKit/Buttons/DisableableButton` preview tap (`.ui`, debug)
- [x] 6.3 Build Presentation package

## 7. App target migration (38 sites)

- [x] 7.1 Link `CottonLoggerKit` in `catowser.xcodeproj/project.pbxproj` (PBXBuildFile, Frameworks phase, packageProductDependencies, XCSwiftPackageProductDependency on the existing Base local package reference)
- [x] 7.2 Migrate `BrowserContent/WebView/` (WebViewController + extensions, WebView, WebViewAuthChallengeHandler, WebViewLoadingErrorHandler — 19 sites) with `.webView`
- [x] 7.3 Migrate `Coordinators/` (AppCoordinator, SearchBarCoordinator — 4 sites) with `.coordinator`
- [x] 7.4 Migrate `WebTabs/` (TabPreviewCell, TabsPreviewsViewController, TabsViewController — 5 sites) with `.tabs`/`.ui`
- [x] 7.5 Migrate `Downloads/` (FileDownloadViewModel, DownloadButtonCellView — 4 sites) with `.downloads`
- [x] 7.6 Migrate remaining app sites (TitledImageView, UIImageView+Extension, FaviconImageViewable, BrowserContent/TopSites — 6 sites) with `.ui`
- [x] 7.7 Build the app target (xcodebuild or Xcode) to verify linking and compilation

## 8. Enforcement and verification

- [x] 8.1 Confirm zero `print(` occurrences in `Base/Sources`, `Domain/Sources`, `Presentation/Sources`, `catowser/` (SwiftLint `print` rule now enforceable)
- [x] 8.2 Run SwiftLint over the repo and fix any new violations introduced by this change
- [ ] 8.3 Manual smoke test: launch the app, browse a page, add/close tabs, and confirm structured log records appear in Console.app under subsystem `com.ae.cotton-browser`
