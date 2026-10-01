## ADDED Requirements

### Requirement: AddTabUseCase owns selection after add
`AddTabUseCase` SHALL decide whether a newly added tab becomes selected using `TabSelectionStrategy.makeTabActiveAfterAdding`, not `TabsDataService` selection-policy logic. When the strategy requires activation, the use case SHALL ensure the selected tab id becomes the new tab’s id (via explicit select-on-add and/or `SelectTabUseCase`) and selected-tab observers/subjects are notified as they are today.

#### Scenario: Add tab that should become selected
- **WHEN** a client adds a tab through `AddTabUseCase` and the selection strategy requires making the new tab active
- **THEN** the tabs list includes the new tab and the selected tab id is the new tab’s id

#### Scenario: Add tab without activating when strategy disallows it
- **WHEN** a client adds a tab through `AddTabUseCase` and the selection strategy does not require making the new tab active
- **THEN** the tabs list includes the new tab and the previously selected tab id remains selected

### Requirement: CloseTabUseCase owns selection after close
`CloseTabUseCase` SHALL compute the next selected tab after a close using `TabSelectionStrategy.autoSelectedIndexAfterTabRemove` with an index context derived from a tabs snapshot (not via strategy invocation inside `TabsDataService`). When selection must change, the use case SHALL apply it (including via `SelectTabUseCase` when appropriate) so selected-tab notifications still occur.

#### Scenario: Close the selected tab with neighbors remaining
- **WHEN** `CloseTabUseCase` closes the currently selected tab and at least one other tab remains
- **THEN** the closed tab is removed and the selected tab id becomes the tab implied by the selection strategy (including nearby behavior when the strategy returns nil but the same index now refers to a different tab)

#### Scenario: Close a non-selected tab
- **WHEN** `CloseTabUseCase` closes a tab that is not selected and the strategy indicates no selection index change
- **THEN** the closed tab is removed and the selected tab id is unchanged

#### Scenario: Close the only remaining tab
- **WHEN** `CloseTabUseCase` closes the last tab
- **THEN** the system ensures a default-content tab exists afterward and that tab is selected

### Requirement: Existing split use cases remain the write API
The system SHALL keep `AddTabUseCase`, `CloseTabUseCase`, `SelectTabUseCase`, and `ReplaceSelectedTabUseCase` as separate use cases. It MUST NOT introduce a combined `WriteTabsUseCase` for these flows. `SelectTabUseCase` SHALL remain available for explicit selection and for orchestration from add/close when applying a computed selection.

#### Scenario: Call sites keep split use case types
- **WHEN** view models or factories request add, close, or select tab behavior
- **THEN** they depend on `AddTabUseCase`, `CloseTabUseCase`, and/or `SelectTabUseCase` rather than a single aggregate write use case

### Requirement: Tabs data service does not own selection strategy
`TabsDataService` SHALL NOT depend on `TabSelectionStrategy` for add/close command handling. Selection policy MUST live in `AddTabUseCase` / `CloseTabUseCase`; the data service MAY still persist and publish an explicitly requested selection (select-on-add flag or select command).

#### Scenario: Service factory no longer requires selection strategy for policy
- **WHEN** the app constructs `TabsDataService` through its factory
- **THEN** construction does not require a `TabSelectionStrategy` solely to decide post-add or post-close selection

#### Scenario: Use case registry wires selection strategy onto add/close
- **WHEN** the app constructs `AddTabUseCase` and `CloseTabUseCase`
- **THEN** those use cases are given a `TabSelectionStrategy` (for example `NearbySelectionStrategy`) used for their selection decisions
