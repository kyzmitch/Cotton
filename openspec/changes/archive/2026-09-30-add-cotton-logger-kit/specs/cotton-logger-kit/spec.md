## ADDED Requirements

### Requirement: Shared logging library in the Base package
The system SHALL provide a `CottonLoggerKit` library target in the Base package (`catowseriOS/Base/Sources/CottonLoggerKit`) with no third-party dependencies. The Domain package, the Presentation package, and the app target SHALL be able to consume the kit without adding any new cross-package dependency edges.

#### Scenario: Domain logs through Base-provided kit
- **WHEN** code in a Domain target emits a log statement
- **THEN** it uses `CottonLoggerKit` imported from the Base package product and the build succeeds without Domain declaring a new package dependency beyond Base

#### Scenario: App target links the kit
- **WHEN** the `catowser` app target is built
- **THEN** it links the `CottonLoggerKit` package product and app-target sources can import and use the kit

### Requirement: Severity levels and minimum-level filtering
`CottonLoggerKit` SHALL define the severity levels `debug`, `info`, `warning`, `error`, and `fault`. `CottonLogger` SHALL expose one method per level. A runtime-configurable minimum level SHALL filter messages: a message whose level is below the configured minimum MUST NOT be delivered to the backend, and its message autoclosure MUST NOT be evaluated.

#### Scenario: Message above minimum level is delivered
- **WHEN** the minimum level is `info` and a logger emits an `error` message
- **THEN** the backend receives exactly one log record with level `error`

#### Scenario: Message below minimum level is skipped
- **WHEN** the minimum level is `info` and a logger emits a `debug` message whose message expression has side effects
- **THEN** the backend receives no log record and the message expression is not evaluated

#### Scenario: Default minimum level
- **WHEN** the app or tests have not changed the configuration
- **THEN** the minimum level is `debug` in debug builds and `info` in release builds

### Requirement: Category routing
`CottonLoggerKit` SHALL define a `Sendable` `LogCategory` type with curated cases (including networking, plugins, rest kit, tabs, search, view models, feature flags, web view, UI, downloads, coordinator, general) plus support for custom string categories. A `CottonLogger` instance SHALL carry one category chosen at init, and every record it emits SHALL carry that category to the backend.

#### Scenario: Logger tags records with its category
- **WHEN** a `CottonLogger` is created with the `.tabs` category and emits messages
- **THEN** each backend record's category equals `.tabs` regardless of call site

#### Scenario: Custom category
- **WHEN** a logger is created with a custom string category
- **THEN** backend records carry that exact category string

### Requirement: Lazy message formatting
All `CottonLogger` level methods SHALL accept the message as an `@autoclosure () -> String` and SHALL default `#fileID`, `#function`, and `#line` source-location parameters. The message closure MUST be evaluated at most once per emitted record.

#### Scenario: Single evaluation for logged message
- **WHEN** a message expression with side effects is logged at or above the minimum level
- **THEN** the expression is evaluated exactly once and the backend receives its result

### Requirement: OSLog-backed default backend with availability fallback
The default backend SHALL emit records to OSLog using subsystem `com.ae.cotton-browser` and the record's category. On `iOS 14`/`macOS 11` and later it SHALL use `os.Logger`; on older systems (Base package floor is iOS 13) it SHALL fall back to `os_log`. The `warning` level, having no `os.Logger` method, SHALL map to the default OSLog severity.

#### Scenario: Modern OS route
- **WHEN** a record is emitted on iOS 14 or later
- **THEN** it is delivered through `os.Logger` with subsystem `com.ae.cotton-browser` and the record's category

#### Scenario: Legacy fallback route
- **WHEN** a record is emitted below iOS 14
- **THEN** it is delivered through `os_log` with the same subsystem, category, and mapped `OSLogType`

### Requirement: Backend injection for tests
`CottonLoggerKit` SHALL allow tests to replace the backend and minimum level at runtime, and the default configuration SHALL be restorable. `LogBackend` SHALL be a `Sendable` protocol so logging works from any concurrency domain under Swift 6 strict concurrency.

#### Scenario: Tests capture log records
- **WHEN** a test installs a capturing backend, emits log messages, and then restores the default configuration
- **THEN** the capturing backend received the emitted records and subsequent logging uses the default backend again

### Requirement: Migration of all print call sites
All 99 `print()` call sites in Base sources (28), Domain sources (31), Presentation sources (2), and the app target (38) SHALL be replaced with `CottonLoggerKit` calls. Message text MUST be preserved. Level selection MUST follow the convention: `catch`-block failures → `error`; unexpected/illegal state → `warning`; lifecycle and interaction traces → `debug`; neutral diagnostics → `info`; process-critical failures → `fault`. Each call site MUST use the category matching its concern (module or feature area).

#### Scenario: No print statements remain
- **WHEN** the migration is complete
- **THEN** no `print(` calls remain in `Base/Sources`, `Domain/Sources`, `Presentation/Sources`, or `catowser/` source files (excluding test targets)

#### Scenario: SwiftLint keeps print out
- **WHEN** a developer adds a new `print()` call in Swift source
- **THEN** SwiftLint reports a `print` rule violation

### Requirement: CottonLoggerKit unit tests
The Base package SHALL include a `CottonLoggerKitTests` test target using Swift Testing that covers minimum-level filtering, lazy message evaluation, category routing, and configuration restore.

#### Scenario: Kit test suite passes
- **WHEN** `swift test` runs for the Base package
- **THEN** the `CottonLoggerKitTests` suite passes and asserts filtering, laziness, and category behavior
