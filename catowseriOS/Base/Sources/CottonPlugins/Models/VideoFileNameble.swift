//
//  VideoFileNameble.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 29/04/2019.
//  Copyright © 2019 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import Foundation

/// Should have properties similar to ones from `Downloadable` protocol
public protocol VideoFileNameble {
    /// The name of the video (e.g. doc title of html)
    var fileDescription: String { get }
}
