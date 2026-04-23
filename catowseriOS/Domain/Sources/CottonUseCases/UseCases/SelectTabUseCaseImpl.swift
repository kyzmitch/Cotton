//
//  SelectTabUseCaseImpl.swift
//  CoreBrowser
//
//  Created by Andrey Ermoshin on 04.01.2024.
//  Copyright © 2024 Cotton (former Catowser). All rights reserved.
//

import CoreBrowser
import CottonTabs
import BaseUseCaseKit

public final class SelectTabUseCaseImpl: SelectTabUseCase {
    private let tabsDataService: any TabsDataServiceProtocol

    public init(_ tabsDataService: any TabsDataServiceProtocol) {
        self.tabsDataService = tabsDataService
    }

    public func execute(input tab: CoreBrowser.Tab) async throws {
        let serviceData = await tabsDataService.sendCommand(.selectTab(tab), nil)
        guard case let .finished(result) = serviceData.tabSelected else {
            throw AppError.commandNotFinishedYet
        }
        switch result {
        case .failure(let error):
            throw AppError.tabsServiceError(error)
        case .success:
            return
        }
    }
}