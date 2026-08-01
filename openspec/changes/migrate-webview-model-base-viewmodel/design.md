## Context

`WebViewModelImpl` is the largest CottonViewModels type still outside ViewModelKit. It maintains:

1. **Domain FSM** — `WebViewModelState` + sync `Actionable.transition(on:)` in `WebViewModelState+Actionable.swift`
2. **Side-effect reactor** — `updateState` → `onStateChange`, which awaits use cases / context and auto-chains further transitions (plugins → DoH → DNS → request → load)
3. **View command bus** — separate `@Published webPageState: WebPageLoadingAction` for recreate/reattach/load/openApp

ViewModelKit already provides `BaseViewModel` + private `ViewModelStateMachine` + `StateTransitioning`. Adopted VMs (SearchBar, BrowserToolbar, AllTabs, TabsPreviews) use a typealias, subclass, context proxy, and dedicated `*StateTransitioning`. ADOPTION.md explicitly forbids wrapping sync `Actionable.transition` as the long-term WebView strategy.

Constraints: Domain targets iOS 15 (`ObservableObject`/Combine); public `WebViewModel` protocol must stay usable by UIKit/SwiftUI; existing DoH concurrency tests must keep meaning; `ViewModelAction` requires manual `allCases` for associated-value enums.

## Goals / Non-Goals

**Goals:**
- `WebViewModelImpl` subclasses `BaseViewModel` and drives domain state only through `sendAction` / `ViewModelStateMachine`
- Async `WebViewStateTransitioning` owns legal transitions; illegal pairs throw (preserve `WebViewModelStateError`)
- `StateContext` exposes DNS, DoH, plugins, tab replace, and `WebPageLoadingAction` emission without leaking the VM type into the strategy
- Preserve public `WebViewModel` method semantics (`load`, `reset`, `decidePolicy`, navigation, JS/DoH toggles, publishers)
- Unit-test strategy transitions (and context-backed async paths) with Swift Testing, without UI

**Non-Goals:**
- Migrating Tab / SearchSuggestions / TopSites in this change
- Using `StateMachineV2` / `ViewModelV2`
- Collapsing `WebPageLoadingAction` into `WebViewModelState` (keep dual channels)
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

Public protocol `WebViewModel` remains the consumer-facing API. Kit `state` / `sendAction` are the internal engine; protocol methods map to `sendAction` (and local policy helpers).

**Why:** Matches AllTabs / SearchBar / Toolbar adoption; avoids inventing a parallel base.

**Alternatives:** Composition (hold a machine without subclassing) — fights `ObservableObject`/`@Published state` conventions already used by the kit.

### D2: Parameterize state by context; `createInitial` → `.pendingLoad`

**Choice:** `WebViewModelState<C: WebViewStateContext>: ViewModelState` with `createInitial() -> .pendingLoad`. Init with an optional `Site` sets published/`machine` state to `.initialized(site)` after `super.init` (same SwiftUI vs UIKit split as today). Keep existing `Equatable` / accessors.

**Why:** Kit requires `createInitial`; `.pendingLoad` is already the SwiftUI-safe empty start. Site-bearing init is a one-time replace, not a fake transition.

**Alternatives:** Fake site in `createInitial` — incorrect for SwiftUI; force every consumer through `reset` only — larger API churn.

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
| Await DoH / resolve DNS / inject plugins / replace tab / remember host | `WebViewStateContext` methods called from strategy **or** from impl after a completed transition when the effect is purely “emit view command” |
| `WebPageLoadingAction` (recreate, reattach, load request, openApp) | Context `emit(_: WebPageLoadingAction)` → impl’s `@Published webPageState` |
| Public method orchestration (`load` still may emit reattach then `sendAction(.loadSite)`) | `WebViewModelImpl` protocol methods |

Auto-chaining that is currently “enter state → immediately send next action” should move toward **context-assisted transitions** so one user-facing `sendAction` can progress through async work without a fragile external reactor. Intermediate states that tests/UI rely on may remain if the strategy still publishes them via successive machine updates **only when necessary**; prefer fewer hops when behavior is identical.

**Why:** SearchBar/AllTabs already put side effects on context; WebView’s reactor is the main complexity to retire.

**Alternatives:** Keep full `onStateChange` switch forever — contradicts migration goal. Put all chaining only in protocol methods — duplicates graph knowledge outside the strategy.

### D5: Keep `webPageState` as a second published channel

**Choice:** Domain FSM state = kit `@Published state`. View load commands remain `@Published webPageState` on the impl (protocol already exposes this). Do not merge into one enum.

**Why:** Consumers already subscribe to `webPageStatePublisher`; merging would be a breaking UI contract for little gain.

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
- Update fixtures to construct `WebViewModelImpl` via new initializer; keep DoH concurrency coverage meaningful
- Use package/test hooks on `BaseViewModel` when asserting `sendAction` paths

**Why:** Aligns with `viewmodel-testability` and AGENTS.md Testing preference.

## Risks / Trade-offs

- **[Risk] Behavior drift while moving `onStateChange` into strategy/context** → Mitigation: port transitions case-by-case; keep existing concurrency tests green; prefer golden-path parity before optimizing hop count.
- **[Risk] Machine/`@Published state` desync on site-bearing init** → Mitigation: after `super.init`, assign initial site state and ensure machine `replaceState` runs (via `sendAction` prelude or explicit package hook) before any action.
- **[Risk] `JavaScriptEvaluateble` / plugin existential equality edge cases** → Mitigation: keep existing `Equatable` rules; avoid relying on equality for existential plugin program cases in tests.
- **[Risk] Large PR** → Mitigation: tasks ordered as conformances → strategy → context → impl wiring → delete Actionable → tests; can land behind green Domain tests.
- **[Trade-off] Dual published streams** → Accepted; clearer than forcing all UI through domain state.

## Migration Plan

1. Add kit conformances + context types without switching the impl yet (if needed for compile isolation).
2. Implement `WebViewStateTransitioning` with async graph + context calls; dual-run or feature-flag only if necessary (prefer direct cutover with strong tests).
3. Rewire `WebViewModelImpl` to `BaseViewModel`, map protocol methods to `sendAction`, remove `updateState`/`onStateChange`/`Actionable`.
4. Update tests/fixtures; remove follow-up comments; update ADOPTION.md WebView note.
5. Rollback: revert the WebViewModel files; kit APIs unchanged.

## Open Questions

- Exact hop-reduction: which intermediate states (e.g. `pendingDoHStatus`) can be internalized entirely inside one async transition vs kept for observability — decide during implementation using existing tests as the bar.
- Whether `WebViewModel` protocol should eventually expose kit `state`/`statePublisher` (not required for this change).
