//
//  SearchClientsFactory.swift
//  catowser
//
//  Created by Andrey Ermoshin on 26/02/2018.
//  Copyright © 2018 andreiermoshin. All rights reserved.
//

import Foundation

enum SearchProviderName {
    case Google
}

struct SearchClientsFactory {
    static func searchSuggestClient(of type: SearchProviderName, handler: @escaping SearchSuggestionsCallback) -> SearchSuggestClient<AlamofireHttpClient> {
        switch type {
        case .Google:
            let searchUrlTemplate = "https://www.google.com/complete/search?client=catowser&amp;q={searchTerms}"
            let googleEngine = SearchEngine(searcherName: "Google", logo: nil, templateType: .Suggest, template: searchUrlTemplate)
            let httpClient = AlamofireHttpClient(endpointAddressString: "https://google.com", acceptHeaderString: SearchTemplateType.Suggest.rawValue, timeout: 4)
            let suggestionsClient = SearchSuggestClient(webSearchEngine: googleEngine, webClient: httpClient, textSearchHandler: handler)
            return suggestionsClient
            
        }
    }
}
