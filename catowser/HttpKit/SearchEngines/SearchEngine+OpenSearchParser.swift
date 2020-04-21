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

public enum OpenSearchError: LocalizedError {
    case noAnyURLXml
    case noTemplateParameter
    case templateIsNotURL
    case notValidURL
    case htmlTemplateUrlNotFound
}

enum ImageEncoding: String {
    case xIcon = "image/x-icon"
}

extension String {
    static let queryTemplate = "{searchTerms}"
}

public extension HttpKit.SearchEngine {
    init(xml element: XMLElement, indexer: XMLIndexer, shortName: String, imageData: Data? = nil) throws {
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
            throw OpenSearchError.noTemplateParameter
        }
        if templateString.contains(String.queryTemplate) {
            templateString = templateString.replacingOccurrences(of: String.queryTemplate, with: "")
        }
        guard let url = URL(string: templateString) else {
            throw OpenSearchError.templateIsNotURL
        }
        
        let optionalComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        guard let components = optionalComponents else {
            throw OpenSearchError.notValidURL
        }
        self.components = components
        let optionalItems = HttpKit.SearchEngine.parseURLParams(indexer: indexer)
        if let items = optionalItems {
            self.queryItems = items
        } else {
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

extension Data {
    static func parseOpenSearchImage(_ imageXmlElement: XMLIndexer) -> Data? {
        let imageData: Data?
        
        if let encodedImageString = imageXmlElement.element?.text {
            let imgWidthStr = imageXmlElement.element?.attribute(by: "width")?.text ?? "16"
            let imgHeightStr = imageXmlElement.element?.attribute(by: "height")?.text ?? "16"
            _ = Int(imgWidthStr, radix: 10) ?? 16
            _ = Int(imgHeightStr, radix: 10) ?? 16
            let imgEncodingTypeStr = imageXmlElement.element?.attribute(by: "type")?.text
            if let encodingTypeStr = imgEncodingTypeStr,
                let _ = ImageEncoding(rawValue: encodingTypeStr) {
                // TODO: add handling for x-icon and for other formats
                imageData = Data(base64Encoded: encodedImageString)
            } else {
                // probably base64
                imageData = Data(base64Encoded: encodedImageString)
            }
        } else {
            imageData = nil
        }
        
        return imageData
    }
}

