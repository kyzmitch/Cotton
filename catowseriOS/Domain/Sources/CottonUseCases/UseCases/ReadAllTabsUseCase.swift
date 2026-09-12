import AutoMockable
import BaseUseCaseKit
import CottonTabs
import CoreBrowser

/// Protocol for reading all tabs asynchronously.
public protocol ReadAllTabsUseCase: CoreUseCase, AutoMockable, Sendable
where Input == Void, Output == [CoreBrowser.Tab] {

    /// Reads all tabs asynchronously.
    ///
    /// - Parameter input: Input parameter, which is `Void` for this use case.
    /// - Returns: An array of `CoreBrowser.Tab`.
    func execute(input: Input) async throws -> Output
}

/// Concrete implementation of `ReadAllTabsUseCase`.
public final class ReadAllTabsUseCaseImpl: ReadAllTabsUseCase {
    /// Service responsible for data operations on tabs.
    private let tabsDataService: any TabsDataServiceProtocol

    /// Initializes the use case with a `TabsDataServiceProtocol`.
    ///
    /// - Parameter tabsDataService: A service conforming to `TabsDataServiceProtocol` for
    ///   data operations on tabs.
    public init(_ tabsDataService: any TabsDataServiceProtocol) {
        self.tabsDataService = tabsDataService
    }

    /// Executes the use case to read all tabs.
    ///
    /// - Parameter input: Input parameter, which is `Void` for this use case.
    /// - Returns: An array of `CoreBrowser.Tab`.
    public func execute(input: Void) async throws -> [CoreBrowser.Tab] {
        let response = await tabsDataService.sendCommand(.getAllTabs, nil)
        guard case let .finished(output: result) = response.allTabs,
              case let .success(value) = result
        else {
            return []
        }
        return value
    }
}
