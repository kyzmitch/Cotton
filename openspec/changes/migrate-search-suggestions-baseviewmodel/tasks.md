## 1. Kit conformances for SearchSuggestions types

- [ ] 1.1 Add `SearchSuggestionsAction` as `ViewModelAction` with cases for sequenced fetch (e.g. `.loadKnownDomains`, `.loadSuggestions`) and optional `.resetToWaiting`, plus a manual representative `allCases` list
- [ ] 1.2 Refactor `SearchSuggestionsViewState` to `ViewModelState` (context type parameter, `Action`/`Context`/`BaseState`, `createInitial` → `.waitingForQuery`); keep existing presentation helpers/`Equatable`
- [ ] 1.3 Add `SearchSuggestionsStateContext` protocol + `SearchSuggestionsStateContextProxy` for known-domains lookup and autocomplete fetch side effects
- [ ] 1.4 Confirm and resolve the duplicate `SearchViewModel/SearchSuggestionsViewState.swift` if it is dead or conflicting

## 2. Async transition strategy

- [ ] 2.1 Add `SearchSuggestionsStateTransitioning` implementing `StateTransitioning` with genuine `async throws` transitions that await context for domains and autocomplete
- [ ] 2.2 Soft-fail autocomplete errors to `.everythingLoaded(domains, [])`; throw on illegal action pairs without mutating state
- [ ] 2.3 Ensure progressive flow is two machine transitions (known domains, then suggestions)—not a single transition that skips the intermediate publish

## 3. Rewire SearchSuggestionsViewModelImpl to BaseViewModel

- [ ] 3.1 Replace the standalone protocol with `typealias SearchSuggestionsViewModel = BaseViewModel<...>` and make `SearchSuggestionsViewModelImpl` subclass it with `super.init(transitioning: SearchSuggestionsStateTransitioning())`
- [ ] 3.2 Override `context` to return the proxy; implement context methods on the impl using `FetchAutocompleteSuggestionsUseCase` + `SearchViewContext`
- [ ] 3.3 Add an orchestration helper (e.g. `fetchSuggestions`) that ONLY sequences `sendAction` calls; cancel overlapping in-flight orchestration Tasks when a newer query starts
- [ ] 3.4 Update `ModuleVMFactory.createSearchSuggestionsVM` to return `SearchSuggestionsViewModel` (concrete typealias), not `any SearchSuggestionsViewModel`

## 4. Update consumers and tests

- [ ] 4.1 Update SwiftUI/UIKit/coordinator/factory/`AppStartInfo` call sites from `any SearchSuggestionsViewModel` + direct protocol `fetchSuggestions` to the typealias + kit `sendAction` / orchestration helper
- [ ] 4.2 Update `SearchSuggestionsVMConcurrencyTests` / fixtures for kit APIs; migrate touched XCTest coverage to Swift Testing where practical
- [ ] 4.3 Add Swift Testing strategy-focused tests (known-domains step, suggestions step, soft-fail, illegal action, progressive publish) per `search-suggestions-kit-adoption` and `viewmodel-testability` delta
- [ ] 4.4 Update `openspec/changes/archive/2026-08-01-mvvm-generic-state-machine/ADOPTION.md` to mark SearchSuggestions as adopted; remove stale follow-up comments if any
- [ ] 4.5 Run Domain / CottonViewModels-related tests and fix regressions
