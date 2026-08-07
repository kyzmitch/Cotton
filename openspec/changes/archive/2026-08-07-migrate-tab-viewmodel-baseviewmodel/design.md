## Context

`TabViewModelImpl` is a CottonViewModels type still outside ViewModelKit. Today it:

1. Conforms to a standalone `TabViewModel` protocol (`load` / `close` / `activate`, `state`, `statePublisher`, plus `TabsObserver`)
2. Mutates `@Published state` directly during async `load`, `tabDidSelect`, and `tabDidReplace` (favicon + selection chrome)
3. Depends on read/close/select tab use cases + `TabViewModelContext` (DoH, favicon URL, web-view removal, iOS 17 `TabsDataSubject`)

ViewModelKit already provides `BaseViewModel` + private `ViewModelStateMachine` + `StateTransitioning`. Adopted VMs (SearchBar, BrowserToolbar, AllTabs, TabsPreviews, WebView, SearchSuggestions) use a typealias, subclass, context proxy, and dedicated `*StateTransitioning`. ADOPTION.md lists Tab as a remaining adopter.

Constraints: Domain targets iOS 15 (`ObservableObject`/Combine); `StateContext` is `AnyObject`; `ViewModelAction` requires manual `allCases` for associated-value enums; `ViewModelState` requires `Equatable` (so `TabViewState` / `ImageSource` need equality); preserve selected/deselected chrome and favicon behavior; keep iOS 17 Observation + legacy `TabsObserver` input paths; do not extend the kit for this adoption.

## Goals / Non-Goals

**Goals:**
- `TabViewModelImpl` subclasses a `BaseViewModel` typealias and drives domain state only through `sendAction` / `ViewModelStateMachine`
- Async `TabStateTransitioning` owns legal transitions; side effects go through a kit `StateContext` proxy
- `TabsObserver` / Observation callbacks become adapters that only `sendAction` (no direct `@Published` writes)
- Consumers (`TabView`, factories, `TabsViewController`) drive via kit `sendAction` / optional thin helpers; observe `state` / `statePublisher`
- Unit-test strategy with Swift Testing without UI
- Update ADOPTION.md to mark Tab adopted

**Non-Goals:**
- Migrating `TopSitesViewModel` in this change
- Using `StateMachineV2` / `ViewModelV2`
- Changing tab product behavior (close/select use cases, favicon resolution rules, selection colors)
- Observation / `@Observable` migration beyond existing iOS 17 tabs wiring
- Making `TabViewModelContext` itself the kit `StateContext` type

## Decisions

### D1: Typealias + subclass; keep TabsObserver on the impl

**Choice:**

```swift
public typealias TabViewModel = BaseViewModel<
    TabViewState<TabStateContextProxy>,
    TabAction,
    TabStateContextProxy
>

final class TabViewModelImpl: TabViewModel { ... }

extension TabViewModelImpl: TabsObserver { /* sendAction only */ }
```

Remove the standalone protocol that redeclares `state` / `statePublisher` / `load` / `close` / `activate`. Factory / array storage (`[TabViewModel]`) use the class typealias (same pattern as AllTabs / SearchSuggestions).

`TabsObserver` stays on `TabViewModelImpl` (not on the typealias) because observation is an input adapter, not part of the kit consumer API. Call sites that only need UI drive (`TabView`) use the typealias; nothing today attaches the protocol existential to `tabsService` as the sole registration path for these VMs.

**Why:** Matches SearchSuggestions/AllTabs; `any` over a class typealias is invalid and unnecessary; protocol added no value beyond kit surface + methods that become actions/helpers.

**Alternatives:** WebView-style protocol refining `ViewModelInterface` + `TabsObserver` — useful when many non-action methods must stay existential; Tab’s extra surface collapses to three helpers + observer adapters. Keep protocol forever — delays kit alignment.

### D2: Parameterize state by context; Equatable; createInitial + title seed

**Choice:** Evolve `TabViewState` to `TabViewState<C: TabStateContext>: ViewModelState` with `createInitial() -> .deSelected("", nil)` (or equivalent empty deselected chrome). Make `ImageSource` (and thus `TabViewState`) `Equatable` in a practical way (e.g. compare URL / image identity / placeholder pair).

After `super.init(transitioning:)`, seed published/machine-visible state to `.deSelected(tab.title, nil)` the same way WebView replaces `.pendingLoad` with a site-bearing init — one-time replace, not a fake transition. Then `load` / observer actions update via the machine.

Keep existing presentation helpers (`selected()`, `deSelected()`, `withNew`).

**Why:** Kit requires `createInitial` with no tab argument; today’s UX shows title immediately before favicon load completes.

**Alternatives:** Fake title in `createInitial` — wrong per instance. Force every consumer through a bootstrap action before first paint — larger churn than a one-time replace. Skip Equatable by changing the kit — out of scope.

### D3: Actions cover load, chrome, close, activate

**Choice:** Introduce `TabAction: ViewModelAction`, for example:

| Action | Effect |
|---|---|
| `.load` | Await selected-tab id + favicon via context; return selected or deselected state with title + favicon |
| `.applySelection(isSelected:)` | From observer select path; flip chrome via `selected()` / `deSelected()` without reloading favicon |
| `.applyReplace(title:favicon:)` | From replace path; keep selection flag, update title/favicon (payload may be resolved in adapter before send, or strategy awaits favicon if given a site handle via context) |
| `.close` | Context removes web view + awaits close-tab use case; state may stay unchanged or VM is discarded by UI |
| `.activate` | Context awaits select-tab use case; selection chrome typically arrives via observer, not this action’s return value |

Orchestration helpers on the typealias/impl:

```swift
func load() { sendAction(.load) }
func close() { sendAction(.close) }
func activate() { sendAction(.activate) }
```

Helpers ONLY call `sendAction` (fire-and-forget or async as today). Prefer updating `TabView` to `sendAction` directly where easy; helpers are acceptable short-lived shims because UIKit targets are fire-and-forget today.

**Why:** Preserves behavior; each transition is one action → one next state; strategy stays unit-testable; close/activate side effects live on context.

**Alternatives:** Keep mutating `@Published` in observer methods — rejects migration goal. One mega-action for all observer payloads — harder to test. Make close/activate pure side effects outside the machine — splits sources of truth; prefer still going through `sendAction` so illegal/logging hooks stay consistent even if next state equals current.

### D4: Kit StateContext + proxy; keep TabViewModelContext as app input

**Choice:** New `TabStateContext: StateContext` (+ `TabStateContextProxy`) with operations the strategy needs, e.g.:

- Resolve whether this tab is selected (read selected tab id / compare)
- Load favicon `ImageSource?` for the current site
- Close tab (use case) + remove web view for site
- Activate/select tab (use case)
- Optionally expose tab identity/title/site for strategy decisions

`TabViewModelImpl` still receives use cases + `TabViewModelContext` (+ feature manager) at init, implements the kit context protocol, and exposes `override var context` via proxy. Strategy never imports the impl type. App `TabViewModelContext` stays FeatureFlags/CottonTabs-facing input and does **not** become the kit context itself.

**Why:** Matches AllTabs/SearchSuggestions proxy pattern; avoids coupling kit `StateContext` to app observing APIs.

**Alternatives:** Make `TabViewModelContext` refine `StateContext` — couples app context to kit and forces use-case injection into the app context. Ignore Template Method `context` — fights kit conventions.

### D5: Observer and Observation are sendAction adapters

**Choice:** `tabDidSelect` / `tabDidReplace` (and iOS 17 Observation handlers that forward into them) MUST NOT assign `state = …`. They compute payloads (and may await favicon via context/helper) then `sendAction(.applySelection…)` / `sendAction(.applyReplace…)`.

Illegal actions throw; published state unchanged. Soft-fail favicon/close/select errors match today (log + continue with nil favicon / print errors).

**Why:** Single writer for domain state is the machine; adapters stay thin.

**Alternatives:** Dual-write during cutover — only if needed mid-PR; remove before completion.

### D6: Consumer migration

**Choice:** Update `TabView`, `TabsViewController` storage, `ModuleVMFactory` / `ViewModelFactory` to the typealias. Replace protocol method calls with `sendAction` or shims. No long-lived deprecated protocol.

**Why:** Call sites are few (`TabView` + factory + tabs VC array).

## Risks / Trade-offs

- **[Equatable / UIImage]** `ImageSource.image` equality may be reference- or png-data-based → Mitigate with a clear Equatable policy documented in code; tests avoid brittle UIImage compares where possible.
- **[Close/activate “no state change”]** Machine still runs a transition that returns current (or equivalent) state → Mitigate by allowing identity transitions for side-effect actions, or returning updated selection only when known without waiting for observer.
- **[Title flash]** `createInitial` empty then seed → Mitigate with post-`super.init` title seed (D2), same as today’s immediate deselected title.
- **[Observer races]** Overlapping load/replace/select → Mitigate with cooperative cancellation where awaits happen; preserve today’s best-effort ordering unless tests prove a regression.
- **[Protocol removal]** Any external module using `any TabViewModel` → Mitigate by grepping call sites; in-repo set is small.

## Migration Plan

1. Add `TabAction`, kit context/proxy, transitioning; make `TabViewState` a `ViewModelState` (+ Equatable/`ImageSource`).
2. Rewire Impl to `BaseViewModel` subclass; remove standalone protocol; seed title after `super.init`; observer methods → `sendAction`.
3. Update UI/factory call sites to typealias + `sendAction` / helpers.
4. Add Swift Testing strategy coverage; fix regressions.
5. Mark Tab adopted in ADOPTION.md.
6. Rollback: revert the change branch; no data migration / feature flag required.

## Open Questions

- Whether `.close` / `.activate` should return unchanged state vs. optimistically flip selection — default: unchanged for close (UI removes the view), unchanged for activate (observer applies selection), unless a call site needs optimistic UI.
- Exact `ImageSource` Equatable rule (URL string equality + image PNG data vs object identity) — decide during apply with the smallest change that satisfies `ViewModelState`.
