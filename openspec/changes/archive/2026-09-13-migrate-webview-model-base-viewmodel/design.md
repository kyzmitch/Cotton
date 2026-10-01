## Context

`WebViewModelImpl` is the largest CottonViewModels type still outside ViewModelKit. It maintains:

1. **Domain FSM** — `WebViewModelState` + sync `Actionable.transition(on:)` in `WebViewModelState+Actionable.swift`
2. **Side-effect reactor** — `updateState` → `onStateChange`, which awaits use cases / context and auto-chains further transitions (plugins → DoH → DNS → request → load)
3. **View command bus** — separate `@Published webPageState: WebPageLoadingAction` for recreate/reattach/load/openApp

ViewModelKit already provides `BaseViewModel` + private `ViewModelStateMachine` + `StateTransitioning`. Adopted VMs (SearchBar, BrowserToolbar, AllTabs, TabsPreviews) use a typealias, subclass, context proxy, and dedicated `*StateTransitioning`. ADOPTION.md explicitly forbids wrapping sync `Actionable.transition` as the long-term WebView strategy.

Constraints: Domain targets iOS 15 (`ObservableObject`/Combine); existing DoH concurrency tests must keep meaning; `ViewModelAction` requires manual `allCases` for associated-value enums. Consumers will be updated in this change to the kit action/observation APIs.

## Goals / Non-Goals

**Goals:**
- `WebViewModelImpl` subclasses `BaseViewModel` and drives domain state only through `sendAction` / `ViewModelStateMachine`
- Async `WebViewStateTransitioning` owns legal transitions; illegal pairs throw (preserve `WebViewModelStateError`)
- `StateContext` exposes DNS, DoH, plugins, tab replace, and loading-command emission without leaking the VM type into the strategy
- Public `WebViewModel` exposes kit `state` / `statePublisher` and `sendAction`; consumers migrate off convenience methods (`load`, `reset`, …)
- Mark `webPageState` / `webPageStatePublisher` as legacy; new/updated consumers use `statePublisher` only
- Unit-test strategy transitions (and context-backed async paths) with Swift Testing, without UI

**Non-Goals:**
- Migrating Tab / SearchSuggestions / TopSites in this change
- Using `StateMachineV2` / `ViewModelV2`
- Immediately deleting the legacy `webPageState` channel (deprecate + dual-write during cutover is enough)
- Rewriting WK navigation / DoH product behavior
- Observation/`@Observable` migration

## Decisions

### D1: Typealias + subclass like other adopters

**Choice:**

```swift
typealias WebViewModelBase = BaseViewModel<
    WebViewModelState<WebViewStateContextProxy>,
    WebViewAction,
    WebViewStateContextProxy
>

final class WebViewModelImpl: WebViewModelBase, WebViewModel { ... }
```

Public protocol `WebViewModel` is the consumer-facing API and **exposes** kit `state` / `statePublisher` / `sendAction`. Convenience methods (`load`, `reset`, …) are removed from the contract (or thin deprecated shims only if a short compile bridge is required during the same PR).

**Why:** Matches AllTabs / SearchBar / Toolbar adoption; avoids inventing a parallel base; aligns consumers with the kit.

**Alternatives:** Composition (hold a machine without subclassing) — fights `ObservableObject`/`@Published state` conventions already used by the kit. Keep forever wrappers around `load`/`reset` — delays the consumer migration this change plans to complete.

### D2: Parameterize state by context; `createInitial` → `.pendingLoad`

**Choice:** `WebViewModelState<C: WebViewStateContext>: ViewModelState` with `createInitial() -> .pendingLoad`. Init with an optional `Site` sets published/`machine` state to `.initialized(site)` after `super.init` (same SwiftUI vs UIKit split as today). Keep existing `Equatable` / accessors.

**Why:** Kit requires `createInitial`; `.pendingLoad` is already the SwiftUI-safe empty start. Site-bearing init is a one-time replace, not a fake transition.

**Alternatives:** Fake site in `createInitial` — incorrect for SwiftUI; force every consumer through `resetToSite` only at init time — larger churn than a one-time replace in `init`.

### D3: Async strategy, not a sync `Actionable` wrapper

**Choice:** New `WebViewStateTransitioning<C>` implements `StateTransitioning`. Port the legal `(state, action) → nextState` graph from `WebViewModelState+Actionable`, but:

- Signature is `async throws`
- Steps that today only exist so `onStateChange` can await (DoH flag, plugin program presence, DNS resolve) **await context** inside the strategy where that simplifies the chain
- Remove `Actionable` conformance / file once call sites are gone

Do **not** ship `func transition(...) async throws { try syncTransition(...) }` as the final design.

**Why:** Matches ADOPTION “fully async” note; enables real unit tests of async failure/cancellation paths.

**Alternatives:** Thin async wrapper around sync graph + keep `onStateChange` reactor unchanged — faster migrate, but leaves the forbidden long-term shape and keeps dual orchestration models.

### D4: Split pure graph vs side effects via context; thin auto-chain

**Choice:**

| Concern | Where it lives |
|---|---|
| Legal next domain state | `WebViewStateTransitioning` |
| Await DoH / resolve DNS / inject plugins / replace tab / remember host | `WebViewStateContext` methods called from strategy **or** from impl after a completed transition when the effect is view-command emission |
| Loading commands (recreate, reattach, load request, openApp) | Context emit → reflected in domain `state` for new consumers; may dual-write legacy `webPageState` during cutover |
| Consumer intent (`loadSite`, `resetToSite`, navigation, …) | Call sites use `sendAction` directly |

Auto-chaining that is currently “enter state → immediately send next action” should move toward **context-assisted transitions** so one user-facing `sendAction` can progress through async work without a fragile external reactor. Intermediate states that tests/UI rely on may remain if the strategy still publishes them via successive machine updates **only when necessary**; prefer fewer hops when behavior is identical.

**Why:** SearchBar/AllTabs already put side effects on context; WebView’s reactor is the main complexity to retire.

**Alternatives:** Keep full `onStateChange` switch forever — contradicts migration goal. Keep orchestration only in convenience methods — conflicts with consumer `sendAction` migration.

### D5: `statePublisher` is primary; `webPageState` is legacy

**Choice:** Kit `@Published state` / `statePublisher` is the **only** observation API for new and updated consumers. Domain state (including cases that imply view work such as `.updatingWebView`, recreate/reattach needs expressed via state or context-driven updates) is what UI observes going forward.

`webPageState` and `webPageStatePublisher` are marked **legacy**: keep temporarily (deprecated) and dual-write from context emits if needed so unmigrated call sites can compile briefly, but do **not** design new UI against them. A follow-up can delete the legacy channel once all subscribers are on `statePublisher`.

**Why:** One observation stream matches other kit adopters and removes the dual-bus mental model for future work. Immediate hard-delete of `webPageState` would widen blast radius; legacy + dual-write is enough for this change.

**Alternatives:** Keep dual channels forever (rejected — user direction is `statePublisher` only). Merge `WebPageLoadingAction` cases into `WebViewModelState` in the same PR without deprecation window — higher risk; prefer state-driven UI with legacy shim first.

### D6: `WebViewAction: ViewModelAction` with manual `allCases`

**Choice:** Conform `WebViewAction` to `ViewModelAction` and supply representative `allCases` (nil/empty associated values), same as SearchBar/Toolbar.

**Why:** Protocol requirement; associated values prevent synthesized `CaseIterable`.

### D7: Context proxy pattern

**Choice:** `WebViewStateContext` protocol + `WebViewStateContextProxy` holding unowned/weak subject `WebViewModelImpl`, mirroring AllTabs/SearchBar. Impl holds use cases (`ResolveDNSUseCase`, tab use cases, `WebViewContext`) and satisfies the context protocol.

**Why:** Strategy stays generic over context; avoids strategy → concrete VM dependency.

### D8: Testing

**Choice:**
- Strategy-only tests for legal/illegal transitions (Swift Testing)
- Context fake for async DoH/DNS branches
- Update fixtures and tests to use `sendAction` (not `load`/`reset` helpers)
- Use package/test hooks on `BaseViewModel` when asserting `sendAction` paths

**Why:** Aligns with `viewmodel-testability` and AGENTS.md Testing preference.

### D9: Expose kit `state` / `statePublisher` on `WebViewModel`

**Choice:** Yes — the public `WebViewModel` protocol MUST expose kit `state` and `statePublisher` (and `sendAction`) so consumers observe and drive the VM the same way as other `BaseViewModel` adopters.

**Why:** Resolved open question; enables retiring convenience methods and the legacy loading publisher.

## Risks / Trade-offs

- **[Risk] Behavior drift while moving `onStateChange` into strategy/context** → Mitigation: port transitions case-by-case; keep existing concurrency tests green; prefer golden-path parity before optimizing hop count.
- **[Risk] Machine/`@Published state` desync on site-bearing init** → Mitigation: after `super.init`, assign initial site state and ensure machine `replaceState` runs (via `sendAction` prelude or explicit package hook) before any action.
- **[Risk] Consumer blast radius (`sendAction` + `statePublisher` migration)** → Mitigation: update all in-repo call sites in the same change; deprecate legacy `webPageState` rather than delete immediately; grep for old method names before merge.
- **[Risk] `JavaScriptEvaluateble` / plugin existential equality edge cases** → Mitigation: keep existing `Equatable` rules; avoid relying on equality for existential plugin program cases in tests.
- **[Risk] Large PR** → Mitigation: tasks ordered as conformances → strategy → context → impl → consumers → delete Actionable → tests.
- **[Trade-off] Legacy `webPageState` during cutover** → Accepted briefly; future code uses `statePublisher` only.

## Migration Plan

1. Add kit conformances + context types.
2. Implement `WebViewStateTransitioning` with async graph + context calls (prefer direct cutover with strong tests).
3. Rewire `WebViewModelImpl` to `BaseViewModel`; expose `state` / `statePublisher` / `sendAction` on `WebViewModel`; mark `webPageState*` legacy (dual-write if needed).
4. Update all in-repo consumers and tests from convenience methods to `sendAction` and from `webPageStatePublisher` to `statePublisher`.
5. Remove `updateState` / `onStateChange` / production `Actionable`; update ADOPTION.md WebView note.
6. Rollback: revert WebViewModel + consumer files; kit APIs unchanged.

## Open Questions

- Exact hop-reduction: which intermediate states (e.g. `pendingDoHStatus`) can be internalized entirely inside one async transition vs kept for observability — decide during implementation using existing tests as the bar.
- How view-specific loading commands (recreate / reattach / `URLRequest` load / openApp) are represented for `statePublisher` consumers (encode in domain state vs derive in the view from state+context) — decide during consumer migration with legacy dual-write as safety net.
