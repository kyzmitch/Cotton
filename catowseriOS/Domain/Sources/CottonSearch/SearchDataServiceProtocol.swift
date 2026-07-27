//
//  SearchDataServiceProtocol.swift
//  CottonDataServices
//
//  Created by Andrey Ermoshin on 05.12.2024.
//  Copyright © 2024 Cotton (Catowser). All rights reserved.
//

import GenericServiceKit

/// Search data service interface
public protocol SearchDataServiceProtocol: GenericDataServiceProtocol, Sendable where
    Command == SearchServiceCommand,
    ServiceData == SearchServiceData,
    ServiceError == SearchServiceError { }
