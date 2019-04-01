//
//  DummyDecodable.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 3/27/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation

// https://stackoverflow.com/a/46713058

/// Type to be able to skip some optional json parts during decoding
public struct CottonDummyDecodable: Decodable {}