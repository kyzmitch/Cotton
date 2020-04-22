//
//  OpenSearchParser.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 4/20/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation
import SWXMLHash

extension OpenSearch {
    public struct Description {
        public let html: HttpKit.SearchEngine
        public let json: HttpKit.SearchEngine?
        
        init(html: HttpKit.SearchEngine, json: HttpKit.SearchEngine?) {
            self.html = html
            self.json = json
        }
        
        public init(data: Data) throws {
            let xml = SWXMLHash.config { (options) in
                    options.detectParsingErrors = true
            }.parse(data)
            
            let rootXml = try xml.byKey("OpenSearchDescription")
            let shortName = try rootXml.byKey("ShortName").element?.text ?? "Unnamed"
            
            let imageXmlElement = try rootXml.byKey("Image")
            let imageResult = OpenSearch.ImageParseResult(image: imageXmlElement)
            
            let urlObjects = rootXml["Url"].all
            guard !urlObjects.isEmpty else {
                throw OpenSearch.Error.noAnyURLXml
            }
            
            var htmlSearchEngine: HttpKit.SearchEngine?
            var jsonSearchEngine: HttpKit.SearchEngine?
            
            for urlXml in urlObjects {
                guard let urlElement = urlXml.element else {
                    continue
                }
                guard let typeString = urlElement.attribute(by: "type")?.text else {
                    continue
                }
                guard let contentType = HttpKit.ContentType(rawValue: typeString) else {
                    continue
                }
                switch contentType {
                case .html:
                    htmlSearchEngine = try .init(xml: urlElement,
                                                 indexer: urlXml,
                                                 shortName: shortName,
                                                 imageData: imageResult)
                case .jsonSuggestions:
                    jsonSearchEngine = try .init(xml: urlElement,
                                                 indexer: urlXml,
                                                 shortName: shortName,
                                                 imageData: imageResult)
                default:
                    print("Unhandled url type for OpenSearch format: \(contentType.rawValue)")
                }
            }
            
            guard let html = htmlSearchEngine else {
                throw OpenSearch.Error.htmlTemplateUrlNotFound
            }
            if let json = jsonSearchEngine {
                // some weird swift bug? only after unwrapping
                // the json object is visible and not nil in debugger
                self.html = html
                self.json = json
            } else {
                self.html = html
                self.json = jsonSearchEngine
            }
        }
    }
}
