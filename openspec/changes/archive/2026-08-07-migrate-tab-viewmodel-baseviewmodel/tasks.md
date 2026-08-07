## 1. Kit conformances for Tab types

- [x] 1.1 Add `TabAction` as `ViewModelAction` with cases for `.load`, `.applySelection`, `.applyReplace`, `.close`, `.activate` (names may match design), plus a manual representative `allCases` list
- [x] 1.2 Refactor `TabViewState` to `ViewModelState` (context type parameter, `Action`/`Context`/`BaseState`, `createInitial` → empty deselected); keep existing presentation helpers; make `ImageSource` + state `Equatable`
- [x] 1.3 Add `TabStateContext` protocol + `TabStateContextProxy` for selection check, favicon resolve, close (incl. web-view removal), and activate side effects

## 2. Async transition strategy

- [x] 2.1 Add `TabStateTransitioning` implementing `StateTransitioning` with genuine `async throws` transitions that await context for load/favicon/close/activate as needed
- [x] 2.2 Soft-fail favicon/close/select errors consistently with today (nil favicon / log); throw on illegal action pairs without mutating state
- [x] 2.3 Ensure selection and replace paths are machine transitions (not direct `@Published` writes)

## 3. Rewire TabViewModelImpl to BaseViewModel

- [x] 3.1 Replace the standalone protocol with `typealias TabViewModel = BaseViewModel<...>` and make `TabViewModelImpl` subclass it with `super.init(transitioning: TabStateTransitioning())`
- [x] 3.2 After `super.init`, seed published state to `.deSelected(tab.title, nil)`; override `context` to return the proxy; implement context methods on the impl using use cases + `TabViewModelContext`
- [x] 3.3 Convert `TabsObserver` / iOS 17 Observation handlers to adapters that ONLY `sendAction`; add thin `load`/`close`/`activate` helpers that ONLY call `sendAction` if needed for cutover
- [x] 3.4 Update `ModuleVMFactory.createTabVM` (and app `ViewModelFactory`) to return `TabViewModel` (concrete typealias)

## 4. Update consumers and tests

- [x] 4.1 Update `TabView` / `TabsViewController` / other call sites from standalone protocol + direct mutations to the typealias + kit `sendAction` / helpers
- [x] 4.2 Add Swift Testing strategy-focused tests (load, selection, replace, illegal action, fake context) per `tab-viewmodel-kit-adoption` and `viewmodel-testability` delta
- [x] 4.3 Update `openspec/changes/archive/2026-08-01-mvvm-generic-state-machine/ADOPTION.md` to mark Tab as adopted
- [x] 4.4 Run Domain / CottonViewModels-related tests and fix regressions
