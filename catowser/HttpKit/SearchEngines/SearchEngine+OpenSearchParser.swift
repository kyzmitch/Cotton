//
//  SearchEngine+OpenSearchParser.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 4/14/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation
import SWXMLHash
import Alamofire // for HTTPMethod type

/**
 https://developer.mozilla.org/en-US/docs/Web/OpenSearch
 */

public enum OpenSearch {}

extension OpenSearch {
    public enum Error: LocalizedError {
        case noAnyURLXml
        case noTemplateParameter
        case templateIsNotURL
        case notValidURL
        case htmlTemplateUrlNotFound
    }
}

extension String {
    static let queryTemplate = "{searchTerms}"
}

extension HttpKit.SearchEngine {
    init(xml element: XMLElement,
         indexer: XMLIndexer,
         shortName: String,
         imageData: OpenSearch.ImageParseResult? = nil) throws {
        
        self.shortName = shortName
        self.imageData = imageData
        
        let httpMethod: HTTPMethod
        if let httpMethodString = element.attribute(by: "method")?.text {
            httpMethod = HTTPMethod(rawValue: httpMethodString) ?? .get
        } else {
            httpMethod = .get
        }
        self.httpMethod = httpMethod
        
        let optionalTemplateString = element.attribute(by: "template")?.text
        guard var templateString = optionalTemplateString else {
            throw OpenSearch.Error.noTemplateParameter
        }
        // FIXME: this is to fix URL initialization below
        if templateString.contains(String.queryTemplate) {
            templateString = templateString.replacingOccurrences(of: String.queryTemplate, with: "")
        }
        guard let url = URL(string: templateString) else {
            throw OpenSearch.Error.templateIsNotURL
        }
        
        let optionalComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        guard let components = optionalComponents else {
            throw OpenSearch.Error.notValidURL
        }
        self.components = components
        let optionalItems = HttpKit.SearchEngine.parseURLParams(indexer: indexer)
        if let items = optionalItems {
            self.queryItems = items
        } else {
            // filter items to not include 'q' item with template value
            self.queryItems = components.queryItems?.filter {!($0.value?.isEmpty ?? true)} ?? []
        }
    }
    
    private static func parseURLParams(indexer: XMLIndexer) -> [URLQueryItem]? {
        let paramsObjects = indexer["Param"].all
        guard !paramsObjects.isEmpty else {
            return nil
        }
        
        var items = [URLQueryItem]()
        for paramXml in paramsObjects {
            guard let element = paramXml.element else {
                continue
            }
            guard let paramName = element.attribute(by: "name")?.text else {
                continue
            }
            guard let paramValue = element.attribute(by: "value")?.text else {
                continue
            }
            guard paramValue != String.queryTemplate else {
                // to not include template value
                continue
            }
            items.append(.init(name: paramName, value: paramValue))
        }
        return items.isEmpty ? nil : items
    }
}

extension OpenSearch {
    enum ImageEncoding: String {
        case xIcon = "image/x-icon"
    }
    
    public enum ImageParseResult {
        case base64(Data)
        case url(URL)
        
        init?(image xmlIndexer: XMLIndexer) {
            guard let encodedImageString = xmlIndexer.element?.text else {
                return nil
            }
            let imgWidthStr = xmlIndexer.element?.attribute(by: "width")?.text ?? "16"
            let imgHeightStr = xmlIndexer.element?.attribute(by: "height")?.text ?? "16"
            _ = Int(imgWidthStr, radix: 10) ?? 16
            _ = Int(imgHeightStr, radix: 10) ?? 16
            let imgEncodingTypeStr = xmlIndexer.element?.attribute(by: "type")?.text
            guard let encodingTypeStr = imgEncodingTypeStr else {
                let imgData = Data(base64Encoded: encodedImageString)
                guard let data = imgData else {
                    return nil
                }
                self = .base64(data)
                return
            }
            guard let knownType = OpenSearch.ImageEncoding(rawValue: encodingTypeStr) else {
                return nil
            }
            
            var imgURL: URL?
            switch knownType {
            case .xIcon:
                imgURL = URL(string: encodedImageString)
            }
            
            guard let iconURL = imgURL else {
                return nil
            }
            self = .url(iconURL)
        }
    }
}
