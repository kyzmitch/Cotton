## Why

`SearchSuggestionsViewModelImpl` still owns its own `@Published` state and mutates it directly inside `fetchSuggestions`, instead of ViewModelKit’s `BaseViewModel` + `ViewModelStateMachine`. That leaves it off the ADOPTION checklist alongside Tab/TopSites, duplicates state-publishing patterns already standardized on SearchBar/AllTabs/WebView, and keeps fetch/transition logic hard to unit-test apart from the concrete impl. The kit APIs and adoption checklist are ready; SearchSuggestions is a small, well-bounded next adopter.

## What Changes

- Migrate `SearchSuggestionsViewModel` / `SearchSuggestionsViewModelImpl` to a `BaseViewModel` typealias driven by `ViewModelStateMachine` and a dedicated `StateTransitioning` strategy.
- Make `SearchSuggestionsViewState` conform to `ViewModelState` (`createInitial` → `.waitingForQuery`); introduce `SearchSuggestionsAction` as `ViewModelAction`.
- Introduce a `StateContext` (+ proxy) so autocomplete fetch, autocompletion source, and known-domains lookup are reachable from transitions without the strategy depending on `SearchSuggestionsViewModelImpl`.
- Preserve progressive UI (`waitingForQuery` → `knownDomainsLoaded` → `everythingLoaded`) via sequenced kit actions (or an equivalent machine-safe approach)—do **not** silently drop the intermediate `knownDomainsLoaded` publish.
- **BREAKING (consumers):** Drive the view model via kit `sendAction` (e.g. `.fetchSuggestions(query)` / sequenced load actions). Keep a thin `fetchSuggestions` convenience only if needed as a short-lived migration shim that solely calls `sendAction`; prefer removing the protocol-only surface in favor of the `BaseViewModel` typealias used by other adopters.
- Update CottonViewModelsTests (concurrency + state fixtures) for `sendAction` / strategy isolation with Swift Testing; migrate remaining XCTest coverage where touched.
- Update ADOPTION.md to mark SearchSuggestions as adopted.

## Capabilities

### New Capabilities
- `search-suggestions-kit-adoption`: SearchSuggestions adopts `BaseViewModel` + `ViewModelStateMachine` with async `StateTransitioning`, a state context for autocomplete/domains side effects, progressive domain→suggestions state publishes, consumer migration to `sendAction` + `statePublisher`, and testable transitions.

### Modified Capabilities
- `viewmodel-testability`: Extend adopter coverage expectations so SearchSuggestions-style progressive async fetches (intermediate then final state) can be unit-tested via strategy/context without UI assemblies.

## Impact

- **CottonViewModels / SearchSuggestions**: `SearchSuggestionsViewModel.swift`, `SearchSuggestionsViewModelImpl.swift`, `SearchSuggestionsViewState.swift`, `SearchViewContext.swift` (and new action/context/transitioning types as needed); `ModuleVMFactory` return type stays compatible with the typealias.
- **ViewModelKit**: No required API changes expected; reuse `BaseViewModel`, `ViewModelStateMachine`, `StateTransitioning`.
- **UI / app consumers**: `SearchSuggestionsView` / `ViewV2`, `SearchSuggestionsViewController`, coordinators/factories that call `fetchSuggestions` MUST switch to `sendAction` (or the temporary shim).
- **Tests**: `SearchSuggestionsVMConcurrencyTests`, `SearchSuggestionsViewStateTests`, plus new strategy-focused Swift Testing coverage.
- **Out of scope**: `TabViewModel`, `TopSitesViewModel`; `StateMachineV2` / `ViewModelV2`; ViewModelKit API redesign for multi-publish mid-transition.
