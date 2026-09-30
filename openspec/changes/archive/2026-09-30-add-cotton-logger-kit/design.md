## Context

The codebase has 99 `print()` call sites with no severity or category information:

| Layer | Package / target | Sites | Examples |
|-------|------------------|-------|----------|
| Base | `CottonNetworking`, `CottonPlugins`, `CottonRestKit` | 28 | `AlamofireHTTPAdaptee`, `BaseJSHandler`, `HTMLContentMessage`, `RestClient` |
| Domain | `CoreBrowser`, `CottonSearch`, `CottonTabs`, `CottonViewModels`, `FeatureFlagsKit`, `GenericServiceKit`, `ViewModelKit` | 31 | `TabsDataService`, `TabViewModelImpl`, `WebViewModelImpl`, `ViewModelConsumer` |
| Presentation | `SearchViews`, `CottonDesignKit` | 2 | `SearchBarLegacyView`, `DisableableButton` (preview/demo) |
| App | `catowser/` | 38 | `WebViewController`, `WebViewAuthChallengeHandler`, `TabsViewController`, coordinators |

Facts that constrain the design:

- Packages are layered `Base` ← `Domain` ← `Presentation` ← app; both Domain and Presentation already depend on Base.
- Base declares `platforms: [.iOS(.v13), .macOS(.v10_15)]`; Domain is iOS 15; Presentation is iOS 17. `os.Logger` requires iOS 14+, so the kit needs an availability fallback for Base's floor.
- All packages compile with `swiftLanguageModes: [.v6]` → strict concurrency; any shared mutable logging configuration must be `Sendable`-safe.
- Project rules: Swift Testing for new tests; SwiftLint per `catowseriOS/.swiftlint.yml` (currently the default `print` rule is active but violated everywhere — this change makes it enforceable).

## Goals / Non-Goals

**Goals:**

- One shared logging API usable from every package and the app target.
- Severity levels with runtime-minimum-level filtering.
- Category routing so logs can be filtered by subsystem (networking, tabs, web view, …).
- Lazy message formatting so filtered-out logs cost nothing.
- OSLog-backed output by default; injectable backend for tests.
- Remove every `print()` call site (99) and keep them out via SwiftLint.

**Non-Goals:**

- Log persistence, export, crash reporting, remote/analytics sinks.
- Changing any app behavior beyond how diagnostics are emitted.
- Rewriting message wording at call sites (keep existing text; level/category only).
- Migrating tests to log through the kit.

## Decisions

### 1. Kit location: new `CottonLoggerKit` target in the Base package

**Choice:** `catowseriOS/Base/Sources/CottonLoggerKit`, exposed as a library product, zero dependencies (Foundation/OSLog only).

**Why:** Domain and Presentation already depend on Base, and the app target already links Base products. Putting the kit in Base requires no new cross-package edges. The app target adds one `XCSwiftPackageProductDependency` for `CottonLoggerKit` (Base local package reference already exists in the project).

**Alternatives considered:**

- Kit in Domain — rejected: Base's own 28 sites couldn't use it (Domain depends on Base, not vice versa).
- Standalone local package — rejected: adds a fourth package reference and folder for one small library.

### 2. API shape: value-type `CottonLogger` with category + level methods

**Choice:**

```swift
public struct CottonLogger: Sendable {
    public let category: LogCategory
    public init(_ category: LogCategory)

    public func debug(_ message: @autoclosure () -> String,
                      file: String = #fileID, function: String = #function, line: Int = #line)
    public func info(_ message: @autoclosure () -> String, ...)
    public func warning(_ message: @autoclosure () -> String, ...)
    public func error(_ message: @autoclosure () -> String, ...)
    public func fault(_ message: @autoclosure () -> String, ...)
}
```

- `@autoclosure` messages keep filtered-out logs cost-free and preserve existing interpolation-heavy call sites with minimal diff.
- Convenience statics per package namespace (e.g. `CottonLogger.networking`, `.plugins`, `.tabs`, `.ui`) are file-scoped extensions where helpful.
- `LogCategory` is a `Sendable` enum with a curated set of cases (`.networking`, `.plugins`, `.restKit`, `.tabs`, `.search`, `.viewModels`, `.featureFlags`, `.webView`, `.ui`, `.downloads`, `.coordinator`, `.general`) plus `.custom(String)` for future needs. Category → OSLog `category` string is a trivial switch (no strategy pattern needed).

**Alternatives considered:**

- Global functions (`Log.error(...)`) — rejected: no category ownership, harder to inject/limit.
- One logger instance per call site via DI — rejected: 99 migration sites; logging is cross-cutting infrastructure, not a service dependency.

### 3. Backend abstraction with OSLog default and iOS 13 fallback

**Choice:**

```swift
public protocol LogBackend: Sendable {
    func log(_ level: LogLevel, category: LogCategory,
             message: String, file: String, function: String, line: Int)
}
```

- Default backend `SystemLogBackend`:
  - `#available(iOS 14.0, macOS 11.0, *)` → `os.Logger(subsystem: "com.ae.cotton-browser", category: category.osLogCategory)` with `Logger.debug/info/error/fault` (`warning` → `.default` level on the `log(_:level:)` path since `Logger` has no `warning` method; map via `OSLogType` using the iOS 15 `OSLogType` init when available, else `.default`).
  - Fallback below availability → `os_log("%{public}@", log: OSLog(subsystem:category:), type: level.osLogType, message)`.
- `LogLevel` (`debug`, `info`, `warning`, `error`, `fault`) maps to `OSLogType` (`.debug`, `.info`, `.default`, `.error`, `.fault`) via a trivial switch.
- Tests inject a capturing backend through configuration (Decision 4).

**Alternatives considered:**

- `print`-only backend — rejected as default; loses Console.app filtering (whole point of the kit).
- Third-party logging (swift-log) — rejected: zero-dependency base package convention; OSLog covers needs.

### 4. Configuration: level filter + backend, stored Sendable-safely

**Choice:** Configuration lives in a `LoggerConfiguration` stored behind a lock (e.g. `NSLock`; `OSAllocatedUnfairLock` is iOS 16-only and Base floors iOS 13):

```swift
public enum LoggerConfiguration {
    public static var minimumLevel: LogLevel   // default: .debug in DEBUG, .info otherwise
    public static var backend: LogBackend      // default: SystemLogBackend
}
```

- Level filtering happens in `CottonLogger` before evaluating the autoclosure.
- Tests set a capturing backend / `.debug` minimum and restore in teardown.
- App may raise `minimumLevel` at startup if needed; no requirement to do so in this change.

**Alternatives considered:**

- `@MainActor`-isolated config — rejected: logging happens from arbitrary concurrency domains (actor data services, network callbacks).

### 5. Migration level conventions

**Choice:** Mechanical mapping, message text preserved:

| Call-site pattern | Level |
|---|---|
| `catch` blocks reporting a failure | `error` |
| Unexpected/illegal state, "shouldn't happen", wrong format | `warning` |
| Lifecycle/interaction traces (`\(#function): show pressed`, navigationType handling) | `debug` |
| Neutral diagnostics ("DOM video tags: N", JS log relays) | `info` |
| Process-critical failures (auth challenge errors, data-service init failure, web process crash) | `fault` |

- Per-file category chosen from the containing module/concern (e.g. `TabsDataService` → `.tabs`, `WebViewAuthChallengeHandler` → `.webView`).
- Call sites keep their existing message strings (including `error.localizedDescription` usage) to keep the migration diff about level/category only.

### 6. Enforcement

**Choice:** Enable SwiftLint's default `print` rule (already active since it's not in `disabled_rules`; migration simply removes the violations). Add no opt-outs; a legitimate one-off can use `// swiftlint:disable:next print` with justification.

### 7. Test strategy

**Choice:** New `CottonLoggerKitTests` test target in Base using Swift Testing:

- Level filtering: below-minimum messages are not evaluated and not delivered.
- Category routing: backend receives the category set at logger init.
- Message evaluation: autoclosure evaluated exactly once when logged, zero times when filtered.
- Configuration restore after tests.

## Risks / Trade-offs

- **[Risk] Swift 6 strict concurrency**: static mutable configuration must be lock-guarded and `LogBackend` must be `Sendable`; `SystemLogBackend` is stateless → trivially safe.
- **[Risk] `warning` has no direct `os.Logger` method** → Mitigation: route `warning` via `log(_:level: .default)`; document mapping in the kit.
- **[Risk] pbxproj edit for app target product dependency** → Mitigation: small, pattern-following edit (one `PBXBuildFile`, one `Frameworks` entry, one `packageProductDependencies` entry, one `XCSwiftPackageProductDependency`); verify by building.
- **[Trade-off] 99-site diff** → unavoidable for a full migration; kept mechanical (level + category only).
- **[Risk] OSLog subsystem string drift vs bundle ids (`com.ae.cotton-browser` / `.debug`)** → Mitigation: constant subsystem `com.ae.cotton-browser` in the kit (subsystem is for Console grouping, not identity checks).

## Migration Plan

1. Add `CottonLoggerKit` target/product/test target to `Base/Package.swift`; implement API + backend + config; add Swift Testing suite.
2. Migrate Base print sites (28) — `CottonNetworking`, `CottonPlugins`, `CottonRestKit`; add `CottonLoggerKit` dependency to those targets.
3. Add `CottonLoggerKit` product dependency to logging Domain targets; migrate Domain sites (31).
4. Add dependency to Presentation targets that log; migrate Presentation sites (2).
5. Link `CottonLoggerKit` in the app target (`catowser.xcodeproj`); migrate app sites (38).
6. Confirm SwiftLint `print` rule passes project-wide; build all packages/tests.
7. Rollback: revert package manifests + call-site migrations together (purely additive kit, safe to delete).

## Open Questions

- (none)
