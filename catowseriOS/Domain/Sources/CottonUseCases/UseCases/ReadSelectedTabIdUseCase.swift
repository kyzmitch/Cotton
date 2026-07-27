import AutoMockable
import BaseUseCaseKit
import CottonTabs
import CoreBrowser

/// Protocol for reading the selected tab ID asynchronously.
public protocol ReadSelectedTabIdUseCase: CoreUseCase, AutoMockable, Sendable {
    /// Input type for the use case. In this case, it's `Void`.
    typealias Input = Void

    /// Output type for the use case, which is a `CoreBrowser.Tab.ID`.
    typealias Output = CoreBrowser.Tab.ID

    /// Reads the selected tab ID asynchronously.
    ///
    /// - Parameter input: Input parameter, which is `Void` for this use case.
    /// - Returns: A `CoreBrowser.Tab.ID` representing the selected tab.
    func execute(input: Input) async throws -> Output
}

/// Concrete implementation of `ReadSelectedTabIdUseCase`.
public final class ReadSelectedTabIdUseCaseImpl: ReadSelectedTabIdUseCase {
    /// Service responsible for data operations on tabs.
    private let tabsDataService: any TabsDataServiceProtocol

    /// Interface responsible for managing the state of tabs.
    private let positioning: TabsStatesInterface

    /// Initializes the use case with `TabsDataServiceProtocol` and `TabsStatesInterface`.
    ///
    /// - Parameters:
    ///   - tabsDataService: A service conforming to `TabsDataServiceProtocol` for
    ///     data operations on tabs.
    ///   - positioning: An interface conforming to `TabsStatesInterface` for
    ///     managing the state of tabs.
    public init(_ tabsDataService: any TabsDataServiceProtocol, _ positioning: TabsStatesInterface) {
        self.tabsDataService = tabsDataService
        self.positioning = positioning
    }

    /// Executes the use case to read the selected tab ID.
    ///
    /// - Parameter input: Input parameter, which is `Void` for this use case.
    /// - Returns: A `CoreBrowser.Tab.ID` representing the selected tab.
    public func execute(input: Void) async throws -> CoreBrowser.Tab.ID {
        let response = await tabsDataService.sendCommand(.getSelectedTabId, nil)
        guard case let .finished(output: result) = response.selectedTabId,
              case let .success(value) = result
        else {
            return positioning.defaultSelectedTabId
        }
        return value
    }
}
