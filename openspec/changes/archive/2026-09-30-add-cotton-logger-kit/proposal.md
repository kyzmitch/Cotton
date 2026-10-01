## Why

Logging today is ad-hoc: 99 raw `print()` statements are scattered across Base (28), Domain (31), Presentation (2), and the app target (38). `print()` has no severity levels, no subsystem/category routing, no filtering, and it always formats its message string — even for verbose diagnostics in release builds. A dedicated logging kit gives uniform severity, categories, testability, and a path to OSLog-based structured logging without touching every call site again later.

## What Changes

- Create a new `CottonLoggerKit` library target in the **Base** package (`catowseriOS/Base/Sources/CottonLoggerKit`) with zero third-party dependencies:
  - Severity levels (`debug`, `info`, `warning`, `error`, `fault`) with a runtime-minimum-level filter.
  - Category-based `CottonLogger` value type (`CottonLogger.networking`, `.plugins`, `.tabs`, …) with lazy (`@autoclosure`) message formatting and `#fileID`/`#function`/`#line` defaults.
  - Pluggable backend: OSLog-based default (structured logging) with an availability fallback for Base's iOS 13 platform floor, and an injection point for tests.
- **Migrate all 99 `print()` call sites** across Base, Domain, Presentation, and the app target to the new API, choosing levels per convention (catch → `error`, unexpected state → `warning`, lifecycle traces → `debug`, informational → `info`).
- Wire the product: `CottonLoggerKit` target/product in `Base/Package.swift`; add it as a dependency of the Domain/Presentation targets that log; add the package product dependency to the app target in `catowser.xcodeproj`.
- Add Swift Testing unit tests for `CottonLoggerKit` (level filtering, category routing, backend capture).

## Capabilities

### New Capabilities
- `cotton-logger-kit`: A shared, category-based, severity-leveled logging API provided by the Base package, backed by OSLog by default and test-injectable, used by all packages and the app target instead of `print()`.

### Modified Capabilities
- (none)

## Impact

- **Base package**: New `CottonLoggerKit` target + product + test target; migrate prints in `CottonNetworking`, `CottonPlugins`, `CottonRestKit` (28 sites).
- **Domain package**: Add `CottonLoggerKit` product dependency to logging targets; migrate prints in `CoreBrowser`, `CottonSearch`, `CottonTabs`, `CottonViewModels`, `FeatureFlagsKit`, `GenericServiceKit`, `ViewModelKit` (31 sites).
- **Presentation package**: Migrate prints in `SearchViews`, `CottonDesignKit` (2 sites).
- **App target (`catowser/`)**: Link `CottonLoggerKit` via Xcode package product dependency; migrate 38 sites (WebView, coordinators, tabs UI, downloads).
- **SwiftLint**: Enforce the default `print` rule so new `print()` calls don't regress the migration.
- **Out of scope**: log persistence/export, remote logging, analytics, changing any behavior other than how messages are emitted.
