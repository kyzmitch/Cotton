## ADDED Requirements

### Requirement: Write use case owns selection after add
The system SHALL decide whether a newly added tab becomes selected in the write use-case layer (using `TabSelectionStrategy.makeTabActiveAfterAdding`), not inside `TabsDataService` selection-policy logic. When the strategy requires activation, the use case SHALL ensure the data service ends with that tab as the selected tab and observers/subjects are notified as they are today for selection changes.

#### Scenario: Add tab that should become selected
- **WHEN** a client adds a tab through the write use case and the selection strategy requires making the new tab active
- **THEN** the tabs list includes the new tab and the selected tab id is the new tab’s id

#### Scenario: Add tab without activating when strategy disallows it
- **WHEN** a client adds a tab through the write use case and the selection strategy does not require making the new tab active
- **THEN** the tabs list includes the new tab and the previously selected tab id remains selected

### Requirement: Write use case owns selection after close
The system SHALL compute the next selected tab after a close in the write use-case layer (using `TabSelectionStrategy.autoSelectedIndexAfterTabRemove` with an index context derived from the post-close tabs snapshot), not via strategy invocation inside `TabsDataService`. When the closed tab was selected (or removal otherwise requires a selection index change per the strategy), the use case SHALL apply the resulting selection through the data service so selected-tab notifications still occur.

#### Scenario: Close the selected tab with neighbors remaining
- **WHEN** the write use case closes the currently selected tab and at least one other tab remains
- **THEN** the closed tab is removed and the selected tab id becomes the tab at the index returned by the selection strategy (or the equivalent remaining tab when the strategy returns nil but the same index now refers to a different tab, matching existing nearby behavior)

#### Scenario: Close a non-selected tab
- **WHEN** the write use case closes a tab that is not selected and the strategy indicates no selection index change
- **THEN** the closed tab is removed and the selected tab id is unchanged

#### Scenario: Close the only remaining tab
- **WHEN** the write use case closes the last tab
- **THEN** the system ensures a default-content tab exists afterward and that tab is selected

### Requirement: Tabs data service does not own selection strategy
`TabsDataService` SHALL NOT depend on `TabSelectionStrategy` for add/close command handling. Selection policy MUST be supplied and applied by the use-case layer; the data service MAY still persist and publish an explicitly requested selection (for example select-on-add flag or a select command).

#### Scenario: Service factory no longer requires selection strategy for policy
- **WHEN** the app constructs `TabsDataService` through its factory
- **THEN** construction does not require a `TabSelectionStrategy` solely to decide post-add or post-close selection

#### Scenario: Use case registry wires selection strategy
- **WHEN** the app constructs the write tabs use case
- **THEN** that use case is given a `TabSelectionStrategy` (for example `NearbySelectionStrategy`) used for add/close selection decisions
