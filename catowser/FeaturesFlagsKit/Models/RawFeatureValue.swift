//
//  RawFeatureValue.swift
//  catowser
//
//  Created by Andrey Ermoshin on 26.02.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation

// Raw types of features we support.
public protocol RawFeatureValue {}
extension Bool: RawFeatureValue {}
extension Int: RawFeatureValue {}
extension String: RawFeatureValue {}
