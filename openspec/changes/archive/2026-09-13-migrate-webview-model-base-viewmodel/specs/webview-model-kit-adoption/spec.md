## ADDED Requirements

### Requirement: WebViewModel uses BaseViewModel and ViewModelStateMachine
`WebViewModelImpl` MUST subclass a `BaseViewModel` typealias parameterized by WebView domain state, `WebViewAction`, and a WebView `StateContext` proxy.

Domain state transitions MUST run only through `sendAction` → private `ViewModelStateMachine` → `StateTransitioning`. The implementation MUST NOT call sync `Actionable.transition` (or an async wrapper that only delegates to that sync API) as the production transition path.

`StateMachineV2` / `ViewModelV2` MUST NOT be used for this adoption.

#### Scenario: loadSite goes through the machine
- **WHEN** a consumer calls `sendAction(.loadSite)` on a view model in `.initialized` (or equivalent ready) state
- **THEN** the domain state advances via the state machine and published kit `state` / `statePublisher` reflects the resulting domain state

#### Scenario: Illegal action preserves state
- **WHEN** an action is invalid for the current `WebViewModelState`
- **THEN** the transition strategy throws a domain error and published domain state remains unchanged

### Requirement: Async WebView transition strategy
CottonViewModels MUST provide a dedicated `StateTransitioning` type for WebView domain state whose `transition(from:on:with:)` is genuinely `async throws` and MAY await the WebView `StateContext` for DoH status, DNS resolution, plugin injection inputs, or tab updates.

#### Scenario: DoH-enabled path awaits context
- **WHEN** a transition needs the current DoH enabled flag or DNS resolution
- **THEN** the strategy awaits context (or context-backed use cases) before returning the next domain state

#### Scenario: Strategy without UI assembly
- **WHEN** a unit test invokes the WebView transition strategy with a fake context
- **THEN** it can assert the next state or thrown error without constructing UIKit/SwiftUI views

### Requirement: WebView state and action kit conformances
`WebViewModelState` MUST conform to `ViewModelState` (including `createInitial`, associated `Action` / `Context` / `BaseState`, and `Equatable`).

`createInitial` MUST return the SwiftUI-safe empty start (`.pendingLoad` or equivalent).

`WebViewAction` MUST conform to `ViewModelAction`, including a manual `allCases` list suitable for associated-value cases.

#### Scenario: Initial state without site
- **WHEN** a WebView view model is constructed without a `Site`
- **THEN** kit domain state starts as the `createInitial` / pending-load state

#### Scenario: Initial state with site
- **WHEN** a WebView view model is constructed with a `Site`
- **THEN** domain state is `.initialized(site)` (or equivalent) before the first load action

### Requirement: StateContext for WebView side effects
A WebView `StateContext` protocol (plus proxy used as the `BaseViewModel` context type) MUST expose the side-effect operations the strategy or impl needs without the strategy depending on `WebViewModelImpl` directly.

Those operations MUST cover at least: emitting view loading commands (for legacy dual-write and/or state-driven UI), reading DoH/native-redirect/plugin-related inputs, resolving DNS, and replacing/updating the selected tab as required by current finish-loading behavior.

#### Scenario: Emit view loading command
- **WHEN** a transition needs the view to recreate, reattach observers, load a request, or open an app URL
- **THEN** context performs the emission such that kit `state` / `statePublisher` remains the primary signal for updated consumers (legacy `webPageState` MAY be dual-written)

#### Scenario: Proxy does not leak into strategy generics beyond Context
- **WHEN** the transition strategy is typed over `State.Context`
- **THEN** it compiles and runs against the proxy/fake context without importing UI layers

### Requirement: Consumers use sendAction and statePublisher
The public `WebViewModel` protocol MUST expose kit `state`, `statePublisher`, and `sendAction`.

In-repo consumers MUST drive the view model with `sendAction` (e.g. `.loadSite`, `.resetToSite`, `.openSite`, `.reload`, `.goBack`, `.goForward`, `.finishLoading`, `.changeJavaScript`, `.changeDoH`, `.loadNextLink`) instead of the old convenience methods (`load`, `reset`, `reload`, `goBack`, `goForward`, `finishLoading`, `setJavaScript`, `setDoH`, …).

Updated consumers MUST observe `statePublisher` (not `webPageStatePublisher`) for UI updates.

`webPageState` and `webPageStatePublisher` MUST be marked legacy/deprecated for the migration window and MUST NOT be the recommended observation API.

#### Scenario: Consumer loads via sendAction
- **WHEN** UI needs to start loading the current site
- **THEN** it calls `sendAction(.loadSite)` (and any required preceding actions) rather than `load()`

#### Scenario: Consumer opens a site via sendAction
- **WHEN** UI needs to show a new `Site` (SwiftUI embed or web-view reuse)
- **THEN** it calls `sendAction(.openSite(site))` rather than `resetToSite` followed by `loadSite`

#### Scenario: Consumer observes statePublisher
- **WHEN** UIKit/SwiftUI subscribes to WebView model updates after migration
- **THEN** it uses `statePublisher` (or `state`) and does not rely on `webPageStatePublisher` as the primary API

#### Scenario: decidePolicy still cancels and loads next link
- **WHEN** `decidePolicy` handles a user link navigation to a different URL
- **THEN** navigation is cancelled and domain state advances via `sendAction(.loadNextLink)` (or equivalent) through the plugins/DoH/load path as today

### Requirement: Actionable sync transitions retired for WebView
After adoption, WebView domain transitions MUST NOT remain owned by a sync `Actionable` extension on `WebViewModelState` as the live production path. Dead `Actionable` types/files for WebView MUST be removed or left unused only transiently during the cutover task, not as the final design.

#### Scenario: No production call to sync Actionable.transition
- **WHEN** the adoption tasks are complete
- **THEN** WebViewModel production code paths invoke `StateTransitioning` via the state machine only
