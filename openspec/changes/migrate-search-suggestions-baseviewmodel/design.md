## Context

`SearchSuggestionsViewModelImpl` is a small CottonViewModels type still outside ViewModelKit. Today it:

1. Conforms to a standalone `SearchSuggestionsViewModel` protocol (`fetchSuggestions`, `state`, `statePublisher`)
2. Mutates `@Published state` directly during an async fetch: `.waitingForQuery` → `.knownDomainsLoaded` → `.everythingLoaded` (or empty suggestions on network failure)
3. Depends on `FetchAutocompleteSuggestionsUseCase` + `SearchViewContext` (autocompletion source + known domains)

ViewModelKit already provides `BaseViewModel` + private `ViewModelStateMachine` + `StateTransitioning`. Adopted VMs (SearchBar, BrowserToolbar, AllTabs, TabsPreviews, and the in-flight WebView migration) use a typealias, subclass, context proxy, and dedicated `*StateTransitioning`. ADOPTION.md lists SearchSuggestions as a remaining adopter.

Constraints: Domain targets iOS 15 (`ObservableObject`/Combine); `StateContext` is `AnyObject`; `ViewModelAction` requires manual `allCases` for associated-value enums; progressive `knownDomainsLoaded` UI must not regress (SwiftUI/UIKit already render that intermediate state); do not extend the kit for mid-transition multi-publish.

## Goals / Non-Goals

**Goals:**
- `SearchSuggestionsViewModelImpl` subclasses a `BaseViewModel` typealias and drives domain state only through `sendAction` / `ViewModelStateMachine`
- Async `SearchSuggestionsStateTransitioning` owns legal transitions; side effects go through a `StateContext` proxy
- Preserve progressive publish of `knownDomainsLoaded` then `everythingLoaded` for a single user query
- Consumers (SwiftUI/UIKit) drive via kit `sendAction` / optional thin orchestration helper; observe `state` / `statePublisher`
- Unit-test strategy (+ progressive sequencing) with Swift Testing without UI
- Update ADOPTION.md to mark SearchSuggestions adopted

**Non-Goals:**
- Migrating `TabViewModel` / `TopSitesViewModel` in this change
- Using `StateMachineV2` / `ViewModelV2`
- Changing ViewModelKit to support multiple publishes inside one `transition`
- Changing autocomplete product behavior (sources, empty-on-error policy, section layout helpers on the state enum)
- Observation / `@Observable` migration

## Decisions

### D1: Typealias + subclass like AllTabs / SearchBar

**Choice:**

```swift
public typealias SearchSuggestionsViewModel = BaseViewModel<
    SearchSuggestionsViewState<SearchSuggestionsStateContextProxy>,
    SearchSuggestionsAction,
    SearchSuggestionsStateContextProxy
>

final class SearchSuggestionsViewModelImpl: SearchSuggestionsViewModel { ... }
```

Remove the standalone protocol. Factory / call sites that today use `any SearchSuggestionsViewModel` switch to the concrete typealias (same pattern as `AllTabsViewModel`).

**Why:** Matches existing adopters; `any` over a class typealias is invalid; protocol adds no value once kit surface (`state`, `statePublisher`, `sendAction`) is the API.

**Alternatives:** Keep a protocol that re-declares kit members — extra indirection with no consumer benefit. Composition without subclassing — fights kit `@Published state` conventions.

### D2: Parameterize state by context; `createInitial` → `.waitingForQuery`

**Choice:** Evolve `SearchSuggestionsViewState` to `SearchSuggestionsViewState<C: SearchSuggestionsStateContext>: ViewModelState` with `createInitial() -> .waitingForQuery`. Keep existing `Equatable` helpers (`rowsCount`, `sectionsNumber`, `value`, `sectionTitle`).

**Why:** Kit requires `createInitial` and associated `Context`; `.waitingForQuery` is already the empty start.

**Alternatives:** Non-generic state with unused context — breaks the `S.Context == C` constraint used by other adopters. Wrapper state type — needless rename churn.

### D3: Two sequenced actions to preserve progressive UI

**Choice:** Because `BaseViewModel.sendAction` publishes only after a full `transition` returns, a single action cannot emit both intermediate and final states without mutating published state out-of-band.

Introduce:

| Action | Effect |
|---|---|
| `.loadKnownDomains(query)` | Await context for domains (+ any source prep needed); return `.knownDomainsLoaded(domains)` |
| `.loadSuggestions(query)` | From `.knownDomainsLoaded` (or tolerant of already-partial state), await autocomplete via context; return `.everythingLoaded(domains, suggestions)` (empty suggestions on failure, same as today) |
| `.resetToWaiting` (optional) | Return `.waitingForQuery` when query cleared / UI resets |

Orchestration for today’s single entry point:

```swift
func fetchSuggestions(_ query: String) async {
    try? await sendAction(.loadKnownDomains(query))
    try? await sendAction(.loadSuggestions(query))
}
```

Prefer exposing this as an extension/helper on the typealias or Impl for call-site convenience during cutover; primary kit API remains `sendAction`. Consumers MAY call the two actions (or `sendActions`) directly.

**Why:** Preserves progressive UI without kit changes; each transition stays pure “one action → one next state”; strategy stays unit-testable per step.

**Alternatives:**
- One action that only publishes `.everythingLoaded` — regresses intermediate list rendering.
- Context mutates `vm.state` mid-transition — dual source of truth; rejected.
- Kit multi-publish API — out of scope.

### D4: StateContext for autocomplete + domains; keep `SearchViewContext` as app input

**Choice:** New `SearchSuggestionsStateContext: StateContext` (+ proxy) with operations the strategy needs, e.g.:

- `knownDomains(matching:)` / access to known-domains lookup
- `autocompleteSuggestions(for:)` (wraps use case + autocompletion source)

`SearchSuggestionsViewModelImpl` still receives `FetchAutocompleteSuggestionsUseCase` + `SearchViewContext` at init, implements the context protocol, and exposes `override var context` via proxy. Strategy never imports the impl type.

**Why:** Matches AllTabs/SearchBar proxy pattern; `SearchViewContext` stays the FeatureFlags/CoreBrowser-facing input and does not need to become `StateContext` itself (it is not necessarily the kit context object).

**Alternatives:** Make `SearchViewContext` refine `StateContext` — couples app context to kit `AnyObject` and forces awkward use-case injection into the app context. Pass use cases only through init and ignore context — fights kit Template Method (`context` on `BaseViewModel`).

### D5: Failure and cancellation behavior

**Choice:**
- Autocomplete failure → `.everythingLoaded(domains, [])` (preserve today’s soft-fail; do not throw to UI for network errors).
- Illegal actions (e.g. `.loadSuggestions` from `.waitingForQuery`) → throw domain error; published state unchanged.
- Overlapping fetches: keep a Task handle on the orchestration helper (same idea as today’s `searchSuggestionsTaskHandler`) to cancel in-flight work when a newer query starts; strategy itself stays cancel-cooperative via `Task.checkCancellation()` where awaits happen.

**Why:** Product behavior stays stable; kit illegal-transition semantics stay strict.

**Alternatives:** Surface network errors as thrown `sendAction` failures — would force every consumer to handle errors and change empty-list UX. Ignore cancellation — can race older responses over newer queries (existing risk we should not worsen).

### D6: Consumer migration

**Choice:** Update SwiftUI (`SearchSuggestionsViewV2`, etc.) and UIKit (`SearchSuggestionsViewController`) to call `sendAction` / orchestration helper instead of protocol `fetchSuggestions`. Replace `any SearchSuggestionsViewModel` with `SearchSuggestionsViewModel` (class typealias) in factories, coordinators, and generics (`S: SearchSuggestionsViewModel` remains valid as a class bound).

**Why:** Aligns with AllTabs/SearchBar factory style; completes ADOPTION for this type in one change (call sites are few).

**Alternatives:** Long-lived deprecated protocol shim — unnecessary given small consumer set.

## Risks / Trade-offs

- **[Progressive UI regression]** If sequencing is collapsed into one action → Mitigate via D3 and explicit scenarios/tests that assert `knownDomainsLoaded` is published before `everythingLoaded`.
- **[Generic state churn]** Parameterizing `SearchSuggestionsViewState` affects UI helpers and tests → Mitigate by keeping case/API surface identical aside from the context generic (typealias helper for the proxy-parameterized state if needed at call sites).
- **[Duplicate state file]** `Domain/Sources/CottonViewModels/SearchViewModel/SearchSuggestionsViewState.swift` appears to duplicate the suggestions state → Mitigate by confirming ownership during implementation and removing/aligning the duplicate if it is dead.
- **[Cancellation races]** Two `sendAction` calls widen the cancel window → Mitigate with orchestration-level Task cancellation + cooperative checks in context awaits.
- **[Concurrent OpenSpec change]** WebView migration listed SearchSuggestions as out of scope → No artifact conflict expected; update ADOPTION only for SearchSuggestions.

## Migration Plan

1. Add action, context/proxy, transitioning; make state a `ViewModelState`.
2. Rewire Impl to `BaseViewModel` subclass; remove standalone protocol; adjust factory return type.
3. Update UI/coordinator/factory call sites to typealias + `sendAction` / helper.
4. Replace/extend tests with Swift Testing strategy + sequencing coverage; keep concurrency behavioral tests meaningful.
5. Mark SearchSuggestions adopted in ADOPTION.md.
6. Rollback: revert the change branch; no data migration / feature flag required.

## Open Questions

- None blocking: optional `.resetToWaiting` only if a consumer currently needs an explicit reset (today’s comment suggests it; verify call sites during apply—if unused, omit until needed).
