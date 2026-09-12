import AutoMockable
import BaseUseCaseKit
import CottonTabs

/// Protocol for reading the count of tabs asynchronously.
public protocol ReadTabsCountUseCase: CoreUseCase, AutoMockable, Sendable {

    /// Reads the count of tabs asynchronously.
    ///
    /// - Parameter input: Input parameter, which is `Void` for this use case.
    /// - Returns: An integer representing the count of tabs.
    func execute(input: Void) async throws -> Int
}

/// Concrete implementation of `ReadTabsCountUseCase`.
public final class ReadTabsCountUseCaseImpl: ReadTabsCountUseCase {
    /// Service responsible for data operations on tabs.
    private let tabsDataService: any TabsDataServiceProtocol

    /// Initializes the use case with a `TabsDataServiceProtocol`.
    ///
    /// - Parameter tabsDataService: A service conforming to `TabsDataServiceProtocol` for
    ///   data operations on tabs.
    public init(_ tabsDataService: any TabsDataServiceProtocol) {
        self.tabsDataService = tabsDataService
    }

    /// Executes the use case to read the count of tabs.
    ///
    /// - Parameter input: Input parameter, which is `Void` for this use case.
    /// - Returns: An integer representing the count of tabs.
    public func execute(input: Void) async throws -> Int {
        let response = await tabsDataService.sendCommand(.getTabsCount, nil)
        guard case let .finished(output: result) = response.tabsCount,
              case let .success(value) = result
        else {
            return 0
        }
        return value
    }
}
