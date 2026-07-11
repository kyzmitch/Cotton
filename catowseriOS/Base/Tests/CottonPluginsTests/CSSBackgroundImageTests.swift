//
//  JSPluginsTests.swift
//  JSPluginsTests
//
//  Created by Andrei Ermoshin on 6/8/20.
//  Copyright © 2020 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import XCTest
@testable import CottonPlugins

class CSSBackgroundImageTests: XCTestCase {

    /// Tests css from style of ytp-cued-thumbnail-overlay-image class div from youtube
    /// it should give a valid URL
    func testYoutubeVideoPreviewURL() throws {
        let input1 = "background-image: url(&quot;https://example.com/picture.png&quot;);"
        let possibleBackgroundImage1 = CSSBackgroundImage(cssString: input1)
        XCTAssertNotNil(possibleBackgroundImage1)
        // swiftlint:disable:next force_unwrapping
        let backgroundImage1 = possibleBackgroundImage1!
        XCTAssertFalse(backgroundImage1.urls.isEmpty)
    }
}
