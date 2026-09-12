//
//  FakeTabSelectionStrategy.swift
//  CottonUseCasesTests
//

import CottonTabs

struct FakeTabSelectionStrategy: TabSelectionStrategy {
    let makeTabActiveAfterAdding: Bool
    var autoSelectedIndexAfterTabRemoveHandler:
        (@Sendable (IndexSelectionContext, Int) async -> Int?)?

    init(
        makeTabActiveAfterAdding: Bool,
        autoSelectedIndexAfterTabRemoveHandler:
            (@Sendable (IndexSelectionContext, Int) async -> Int?)? = nil
    ) {
        self.makeTabActiveAfterAdding = makeTabActiveAfterAdding
        self.autoSelectedIndexAfterTabRemoveHandler = autoSelectedIndexAfterTabRemoveHandler
    }

    func autoSelectedIndexAfterTabRemove(
        context: IndexSelectionContext,
        removedIndex: Int
    ) async -> Int? {
        if let autoSelectedIndexAfterTabRemoveHandler {
            return await autoSelectedIndexAfterTabRemoveHandler(context, removedIndex)
        }
        return await NearbySelectionStrategy().autoSelectedIndexAfterTabRemove(
            context: context,
            removedIndex: removedIndex
        )
    }
}
