//
//  TabsServiceData.swift
//  CottonDataServices
//
//  Created by Andrey Ermoshin on 20.01.2024.
//  Copyright © 2024 Cotton (former Catowser). All rights reserved.
//

import CoreBrowser
import GenericServiceKit

/// Tab's index type
public typealias TabIndex = Array<Tab>.Index
/// Selected tab id type
public typealias SelectedTabId = Tab.ID

/// Tabs count service data
public typealias TabsCountData = CommandExecutionData<Void, Int, TabsListError>
/// Selected tab service data
public typealias SelectedTabData = CommandExecutionData<Void, Tab.ID, TabsListError>
/// All tabs service data
public typealias AllTabsData = CommandExecutionData<Void, [Tab], TabsListError>

/// Input can be a newly added tab, but it is passed in a command.
/// Output is the index of the added tab.
public typealias AddTabData = CommandExecutionData<
    Void,
    TabIndex,
    TabsListError
>
/// Input can be a tab id which needs to be closed, but that info is passed in a command.
/// Output is a tab id which is a new selected tab if the closed tab was selected one.
/// New selected tab id output is optional in case if the closed tab wasn't selected and it
/// doesn't change the selection.
public typealias CloseTabData = CommandExecutionData<
    Void,
    SelectedTabId?,
    TabsListError
>

/// Close all tabs service data
public typealias CloseAllTabsData = CommandExecutionData<Void, Void, TabsListError>
/// Select tab service data
public typealias SelectTabData = CommandExecutionData<Void, Void, TabsListError>
/// Replace tab service data
public typealias ReplaceTabContentData = CommandExecutionData<Void, Void, TabsListError>
/// Update tab preview service data
public typealias UpdateTabPreviewData = CommandExecutionData<Void, Void, TabsListError>

/// Tabs service data output/response type.
public struct TabsServiceData: GenericServiceData, Sendable {
    /// Init
    public init() {
        tabsCount = .notStarted
        selectedTabId = .notStarted
        allTabs = .notStarted
        tabAdded = .notStarted
        tabClosed = .notStarted
        allTabsClosed = .notStarted
        tabSelected = .notStarted
        tabContentReplaced = .notStarted
        tabPreviewUpdated = .notStarted
    }
    
    /// Need an optimization and use data from `allTabs`
    /// to have a single source of truth, but
    /// at the same time still need to have a state for command execution
    public var tabsCount: TabsCountData
    /// Contains the cache for the selected tab id
    public var selectedTabId: SelectedTabData
    /// Contains the cache for all the tabs
    public var allTabs: AllTabsData
    /// Result of newly added tab
    public var tabAdded: AddTabData
    /// Result of closed tab
    public var tabClosed: CloseTabData
    /// Result of all tabs closed
    public var allTabsClosed: CloseAllTabsData
    /// Result of tab selected
    public var tabSelected: SelectTabData
    /// Result of tab content replaced
    public var tabContentReplaced: ReplaceTabContentData
    /// Result of tab preview updated
    public var tabPreviewUpdated: UpdateTabPreviewData
}

// extension TabsServiceData: Equatable {}
