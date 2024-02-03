//
//  CSSBackgroundImage.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 6/8/20.
//  Copyright © 2020 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import Foundation
import CssParser

/**
Wanted to use SwiftCssParser library but it can't be integrated over CocoaPods
https://github.com/100mango/SwiftCssParser/issues/4
https://www.w3schools.com/cssref/pr_background-image.asp
CSS syntax: background-image: url|none|initial|inherit;
example: background-image: url("img_tree.gif"), url("paper.gif");

So that, it's possible to find more than 1 url, but for youtube it's one.
*/

/// CSS related model which parses background image atribute
struct CSSBackgroundImage {
    let urls: [URL]
    
    var firstURL: URL {
        // swiftlint:disable:next force_unwrapping
        return urls.first!
    }
    
    init?(cssString: String) {
        /**
         https://developer.mozilla.org/en-US/docs/Web/CSS/url()
         "background-image: url(&quot;https://example.com/picture.png&quot;);"
         or
         "background-image: url(\"https://example.com/picture.png\");"
         */
        
        guard cssString.range(of: "background-image") != nil else {
            return nil
        }
        /**
         Need to use https://github.com/jotform/css.js
         and write wrapper using https://developer.apple.com/documentation/javascriptcore
         can use https://github.com/darkcl/CSSwift as an example.
         Not good to use it, because it is old and uses Objective-c and it's not safly implemented.
         Will use something similar to https://github.com/hashemi/mutatali but with additional code
         to return URL instead of String for our case.
         */
        
        // removing quotes probably caused by JSON.stringify
        let source = cssString.replacingOccurrences(of: "&quot;", with: "")
        let scanner = Scanner(source: source)
        let cssTokens: [Token]
        do {
            cssTokens = try scanner.scanTokens()
        } catch {
            assertionFailure("Fail to parse CSS: \(error.localizedDescription)")
            return nil
        }
        let urls = cssTokens
            .filter {
                switch $0 {
                case .url:
                    return true
                default:
                    return false
                }
        }.compactMap { (token) -> URL? in
            switch token {
            case .url(value: let urlString):
                return URL(string: urlString)
            default:
                return nil
            }
        }
        guard !urls.isEmpty else {
            return nil
        }
        self.urls = urls
    }
}
