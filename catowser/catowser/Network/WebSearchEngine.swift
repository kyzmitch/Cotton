//
//  WebSearchEngine.swift
//  catowser
//
//  Created by Andrey Ermoshin on 25/02/2018.
//  Copyright © 2018 andreiermoshin. All rights reserved.
//

import Foundation
import UIKit

enum SearchTemplateType: String {
    typealias RawValue = String
    
    case Search = "text/html"
    case Suggest = "application/x-suggestions+json"
}

protocol WebSearchEngine {
    var shortName: String {get set}
    var logoImage: UIImage? {get set}
    var searchTemplateType: SearchTemplateType {get set}
    var searchTemplate: String {get set}
    
    func urlForQuery(_ query: String) -> URL?
}

struct SearchEngine: WebSearchEngine {
    var shortName: String
    var logoImage: UIImage?
    var searchTemplateType: SearchTemplateType
    var searchTemplate: String
    
    // standirtized substrings to find place to insert real data
    // to get needed url for search request
    fileprivate let SearchTermComponent = "{searchTerms}"
    fileprivate let LocaleTermComponent = "{moz:locale}"
    
    init(searcherName: String, logo: UIImage?, templateType: SearchTemplateType, template: String) {
        shortName = searcherName
        logoImage = logo
        searchTemplateType = templateType
        searchTemplate = template
    }
    
    func urlForQuery(_ query: String) -> URL? {
        // 1st verifying query string input
        if let escapedQuery = query.addingPercentEncoding(withAllowedCharacters: .SearchTermsAllowed) {
            // 2nd preparing allowed symbols for final URL
            var templateAllowedSet = CharacterSet()
            templateAllowedSet.formUnion(.URLAllowed)
            templateAllowedSet.formUnion(CharacterSet(charactersIn: "{}"))
            
            // 3rd verifying full address string
            if let encodedSearchTemplate = searchTemplate.addingPercentEncoding(withAllowedCharacters: templateAllowedSet) {
                let localeString = Locale.current.identifier
                let urlString = encodedSearchTemplate
                    .replacingOccurrences(of: SearchTermComponent, with: escapedQuery, options: .literal, range: nil)
                    .replacingOccurrences(of: LocaleTermComponent, with: localeString, options: .literal, range: nil)
                return URL(string: urlString)
            }
        }
        
        return nil
    }
}
