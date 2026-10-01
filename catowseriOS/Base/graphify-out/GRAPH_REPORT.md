# Graph Report - Base  (2026-09-30)

## Corpus Check
- 106 files · ~34,260 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1042 nodes · 1815 edges · 68 communities (59 shown, 4 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 37 edges (avg confidence: 0.84)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `048b0bc0`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- AnyObject
- RxObserverVoidWrapper
- ResponseHandlingApi
- DownloadError
- .makeAuthorizedRequestProducer
- ResponseType
- Token
- DnsError
- CottonPluginError
- CottonRestKit
- HttpError
- .resolvedDomainName
- DnsRR
- Foundation
- Downloadable.swift
- Sendable
- AutoMockable
- Scanner
- ComponentValue
- LogCategory
- InstagramVideoNode
- CapturingLogBackend
- AlamofireHTTPAdaptee
- Character
- LogLevel
- RestClient
- ClosureWrapper
- CottonBase
- ResponseVoidHandlingApi
- MockedHTTPAdapteeWithFail
- HTMLVideoTag
- package.json
- AlamofireHTTPRxVoidAdaptee
- ig.js
- ClosureVoidWrapper
- .makeRxRequest
- LoggerConfiguration
- CSSBackgroundImage
- CottonLogger
- CodingKeys
- NetworkReachabilityAdapter
- .makeRequest
- HTMLContentMessage
- CodingKeys
- CottonRestKit/Extensions/HttpKotlinTypes+Extensions.swift
- .failure
- URL
- AutoMockable.swift
- GoogleDNSEndpointError
- Parser
- .init
- BaseTests.swift
- .makeRequestProducer
- Combine+Extensions.swift
- GoogleDNSOverJSONResponse
- README.md
- GDNSRequestParams
- Package.swift
- .init
- HashType
- NumberType
- MessageKey
- .makeRequestFuture

## God Nodes (most connected - your core abstractions)
1. `HttpError` - 59 edges
2. `CottonBase` - 53 edges
3. `Token` - 53 edges
4. `RestClient` - 51 edges
5. `Scanner` - 27 edges
6. `ResponseHandlingApi` - 24 edges
7. `LogCategory` - 23 edges
8. `CottonRestKit` - 22 edges
9. `Character` - 21 edges
10. `ResponseVoidHandlingApi` - 18 edges

## Surprising Connections (you probably didn't know these)
- `HttpClientTests` --calls--> `RestClient`  [INFERRED]
  Tests/CottonRestKitTests/HttpClientTests.swift → Sources/CottonRestKit/RestClient.swift
- `CapturingLogBackend` --inherits--> `LogBackend`  [EXTRACTED]
  Tests/CottonLoggerKitTests/CottonLoggerKitTests.swift → Sources/CottonLoggerKit/LogBackend.swift
- `Record` --references--> `LogCategory`  [EXTRACTED]
  Tests/CottonLoggerKitTests/CottonLoggerKitTests.swift → Sources/CottonLoggerKit/LogCategory.swift
- `Record` --references--> `LogLevel`  [EXTRACTED]
  Tests/CottonLoggerKitTests/CottonLoggerKitTests.swift → Sources/CottonLoggerKit/LogLevel.swift
- `HTMLContentMessage` --references--> `CottonBase`  [EXTRACTED]
  Sources/CottonPlugins/Models/HTMLContentMessage.swift → Tests/CottonRestKitTests/ReachabilityAdapteeMocks.swift

## Import Cycles
- None detected.

## Communities (68 total, 4 thin omitted)

### Community 0 - "AnyObject"
Cohesion: 0.05
Nodes (43): AnyObject, Client, Equatable, HttpKitRxSubscriber, HttpKitSubscriber, NSObject, Program, RestClientContext (+35 more)

### Community 1 - "RxObserverVoidWrapper"
Cohesion: 0.05
Nodes (40): RR, HTTPRxAdapter, Endpoint, Response, Server, Signal, Void, Lifetime (+32 more)

### Community 2 - "ResponseHandlingApi"
Cohesion: 0.06
Nodes (36): ResponseApi, AlamofireHTTPRxAdaptee, Endpoint, Future, Int, ObserverWrapper, Response, Result (+28 more)

### Community 3 - "DownloadError"
Cohesion: 0.12
Nodes (15): DownloadError, .errorDescription, failedCreateFileProviderFolder, failedExcludeFromBackup, networkError, noAppGroupDirectory, noContentLengthHeader, noCorrectDownloadDestination (+7 more)

### Community 4 - ".makeAuthorizedRequestProducer"
Cohesion: 0.26
Nodes (11): RxSub, B, Endpoint, ResponseFuture, RX, RxProducer, RxSubscriber, Server (+3 more)

### Community 5 - "ResponseType"
Cohesion: 0.05
Nodes (31): CGSearchPublisher, DDGoSuggestionsClientRxSubscriber, DDGoSuggestionsClientSubscriber, DDGoSuggestionsEndpoint, DDGoSuggestionsProducer, DDGoSuggestionsPublisher, GSearchClientRxSubscriber, GSearchClientSubscriber (+23 more)

### Community 6 - "Token"
Cohesion: 0.05
Nodes (36): Double, Int, String, Token, atKeyword, badString, badUrl, cdc (+28 more)

### Community 7 - "DnsError"
Cohesion: 0.10
Nodes (21): ResolvedURLPublisher, DnsError, .errorDescription, failToGetUrlFromComponents, hostIsNotIpAddress, httpError, noHost, notHttpScheme (+13 more)

### Community 8 - "CottonPluginError"
Cohesion: 0.07
Nodes (26): Error, CottonPluginError, emptyHtml, .errorDescription, jsEvaluationIsNotString, jsEvaluationIsNotURL, jsFileNotFound, nilJSEvaluationResult (+18 more)

### Community 9 - "CottonRestKit"
Cohesion: 0.22
Nodes (6): Alamofire, Combine, CottonReactiveRestKit, CottonRestKit, ReactiveSwift, HTTPRxVoidAdapter

### Community 10 - "HttpError"
Cohesion: 0.08
Nodes (25): HttpError, emptyQueryParam, failedConstructRequestParameters, failedEncodeEncodable, failedKotlinRequestConstruct, httpFailure, invalidDomainName, invalidURL (+17 more)

### Community 11 - ".resolvedDomainName"
Cohesion: 0.16
Nodes (10): GDNSJsonClientRxSubscriber, GDNSJsonClientSubscriber, GDNSjsonEndpoint, GDNSjsonProducer, GDNSjsonPublisher, Endpoint, AnyPublisher, ResolvedURLProducer (+2 more)

### Community 12 - "DnsRR"
Cohesion: 0.24
Nodes (9): RawRepresentable, DNSRecordType, addressRecord, canonicalName, .knownCase, DnsRR, String, UInt32 (+1 more)

### Community 13 - "Foundation"
Cohesion: 0.15
Nodes (7): CottonLogs, Foundation, String, String, String, SwiftSoup, WebKit

### Community 14 - "Downloadable.swift"
Cohesion: 0.13
Nodes (18): CryptoKit, DownloadRequest, FileDownloadProducer, Progress, RemoteFileInfoProducer, download(), Downloadable, .excludeFromBackup (+10 more)

### Community 15 - "Sendable"
Cohesion: 0.06
Nodes (35): SecTrust, Sendable, ServerDescription, SignalProducer, Alamofire.NetworkReachabilityManager.NetworkReachabilityStatus, Alamofire.NetworkReachabilityManager.NetworkReachabilityStatus.ConnectionType, .httpKitValue, .httpKitValue (+27 more)

### Community 16 - "AutoMockable"
Cohesion: 0.13
Nodes (13): AutoMockable, JSONEncoding, Any, String, URLRequest, JSONRequestEncodable, URLRequest, URLRequestCreatable (+5 more)

### Community 17 - "Scanner"
Cohesion: 0.23
Nodes (7): Scanner, .currentText, .isAtEnd, .peek1, .peek2, .peek3, String

### Community 18 - "ComponentValue"
Cohesion: 0.18
Nodes (18): AtRule, Category, descriptor, property, ComponentValue, function, preservedToken, simpleBlock (+10 more)

### Community 19 - "LogCategory"
Cohesion: 0.12
Nodes (16): LogCategory, coordinator, custom, downloads, featureFlags, general, networking, .osLogCategory (+8 more)

### Community 20 - "InstagramVideoNode"
Cohesion: 0.16
Nodes (13): CGSize, Decodable, Data, CottonDummyDecodable, InstagramVideoArray, Decoder, IgEdgeMediaCaption, IgMediaCaptionEdge (+5 more)

### Community 21 - "CapturingLogBackend"
Cohesion: 0.25
Nodes (8): CottonLoggerKit, T, CapturingLogBackend, CottonLoggerKitTests, messageWithSideEffect(), Record, Int, String

### Community 22 - "AlamofireHTTPAdaptee"
Cohesion: 0.23
Nodes (10): AlamofireHTTPAdaptee, Endpoint, Future, Int, Response, Result, RxFreeDummy, Server (+2 more)

### Community 23 - "Character"
Cohesion: 0.13
Nodes (14): Character, .isDigit, .isHexDigit, .isLetter, .isLowercase, .isMaximumAllowed, .isName, .isNameStart (+6 more)

### Community 24 - "LogLevel"
Cohesion: 0.14
Nodes (13): Comparable, Int, OSLog, OSLogType, LogLevel, debug, error, fault (+5 more)

### Community 25 - "RestClient"
Cohesion: 0.16
Nodes (9): E, String, URL, RestClient, Encoder, R, S, Server (+1 more)

### Community 26 - "ClosureWrapper"
Cohesion: 0.31
Nodes (9): ClosureWrapper, CombinePromiseWrapper, Endpoint, Future, Hasher, Response, Result, Server (+1 more)

### Community 27 - "CottonBase"
Cohesion: 0.12
Nodes (3): CottonBase, Network, Security

### Community 28 - "ResponseVoidHandlingApi"
Cohesion: 0.14
Nodes (13): Hashable, Observer, Server, ResponseVoidHandlingApi, asyncAwaitConcurrency, closure, combine, rxObserver (+5 more)

### Community 29 - "MockedHTTPAdapteeWithFail"
Cohesion: 0.22
Nodes (10): MockedHTTPAdapteeWithFail, Endpoint, Future, Int, ObserverWrapper, Response, Result, Server (+2 more)

### Community 30 - "HTMLVideoTag"
Cohesion: 0.26
Nodes (8): Element, HTMLVideoTag, Decoder, Int, String, URL, HTMLVideoTagsContainer, VideoFileNameble

### Community 31 - "package.json"
Cohesion: 0.15
Nodes (12): eslint, author, description, devDependencies, eslint, license, main, name (+4 more)

### Community 32 - "AlamofireHTTPRxVoidAdaptee"
Cohesion: 0.22
Nodes (9): AlamofireHTTPRxVoidAdaptee, Endpoint, Future, Int, ObserverWrapper, Result, Server, URLRequest (+1 more)

### Community 33 - "ig.js"
Cohesion: 0.36
Nodes (12): cottonFindTitleFromNode(), cottonHandleHtml(), cottonHandleHttpResponseText(), cottonIsIgEnabled(), cottonLog(), cottonNativeAppSendSingleNode(), cottonSearchAdditionalData(), cottonSearchSharedData() (+4 more)

### Community 34 - "ClosureVoidWrapper"
Cohesion: 0.31
Nodes (8): ClosureVoidWrapper, CombinePromiseVoidWrapper, Endpoint, Future, Hasher, Result, Server, Void

### Community 35 - ".makeRxRequest"
Cohesion: 0.33
Nodes (6): MockedGoodEndpoint, B, Endpoint, Server, String, HttpClientTests

### Community 36 - "LoggerConfiguration"
Cohesion: 0.20
Nodes (7): os, LogBackend, LoggerConfiguration, .backend, .defaultMinimumLevel, .minimumLevel, SystemLogBackend

### Community 37 - "CSSBackgroundImage"
Cohesion: 0.18
Nodes (8): CottonPlugins, CssParser, CSSBackgroundImage, .firstURL, URL, CSSBackgroundImageTests, XCTest, XCTestCase

### Community 38 - "CottonLogger"
Cohesion: 0.22
Nodes (7): CottonLogger, Int, String, Any, WKScriptMessage, WKScriptMessage, .mainPosterURL

### Community 39 - "CodingKeys"
Cohesion: 0.20
Nodes (10): CodingKeys, displayUrl, isVideo, mediaCaption, mediaPreview, pageTitle, thumbnailSrc, typeName (+2 more)

### Community 40 - "NetworkReachabilityAdapter"
Cohesion: 0.10
Nodes (13): NetworkReachabilityManager, AlamofireReachabilityAdaptee, Bool, DispatchQueue, Listener, Server, NetworkReachabilityAdapter, Server (+5 more)

### Community 41 - ".makeRequest"
Cohesion: 0.56
Nodes (5): B, Endpoint, Server, String, T

### Community 42 - "HTMLContentMessage"
Cohesion: 0.29
Nodes (6): HTMLContentMessage, Decoder, URL, Document, .documentTitle, String

### Community 43 - "CodingKeys"
Cohesion: 0.29
Nodes (7): CodingKey, CodingKeys, hostname, htmlString, CodingKeys, poster, src

### Community 44 - "CottonRestKit/Extensions/HttpKotlinTypes+Extensions.swift"
Cohesion: 0.15
Nodes (11): Array, .kotlinArray, HTTPRequestInfo, .urlRequest, KotlinArray, .empty, Set, .dictionary (+3 more)

### Community 45 - ".failure"
Cohesion: 0.53
Nodes (4): Failure, Output, Combine.Future, Future

### Community 46 - "URL"
Cohesion: 0.33
Nodes (5): HostProducer, ResolvedURLProducer, String, URL, .rxHttpHost

### Community 47 - "AutoMockable.swift"
Cohesion: 0.33
Nodes (5): AutoHashable, AutoMockable, ProcessInfo, .unitTesting, Bool

### Community 48 - "GoogleDNSEndpointError"
Cohesion: 0.17
Nodes (10): LocalizedError, GoogleDNSEndpointError, dnsStatusError, emptyAnswers, .errorDescription, recordTypeParsing, Int32, String (+2 more)

### Community 49 - "Parser"
Cohesion: 0.33
Nodes (3): Parser, .current, .next

### Community 50 - ".init"
Cohesion: 0.40
Nodes (4): Reachability, Encoder, Server, TimeInterval

### Community 52 - ".makeRequestProducer"
Cohesion: 0.23
Nodes (10): RxVoidProducer, RxVoidSubscriber, B, Endpoint, RX, RxProducer, RxSubscriber, Server (+2 more)

### Community 54 - "GoogleDNSOverJSONResponse"
Cohesion: 0.21
Nodes (12): Answer, CodingKeys, answer, ipAddress, name, status, type, GoogleDNSOverJSONResponse (+4 more)

### Community 55 - "README.md"
Cohesion: 0.50
Nodes (3): Initial setup was, Intallation, JavaScript info

### Community 56 - "GDNSRequestParams"
Cohesion: 0.24
Nodes (8): GSearchEndpoint, Endpoint, GDNSRequestParams, .urlQueryItems, Bool, DomainName, String, URLQueryItem

### Community 60 - "HashType"
Cohesion: 0.67
Nodes (3): HashType, id, unrestricted

### Community 61 - "NumberType"
Cohesion: 0.67
Nodes (3): NumberType, integer, number

### Community 62 - "MessageKey"
Cohesion: 0.22
Nodes (9): MessageKey, DOMVideoTags, html, log, MessageKey, log, singleVideoNode, videoNodes (+1 more)

### Community 67 - ".makeRequestFuture"
Cohesion: 0.25
Nodes (7): B, Endpoint, ResponseFuture, Server, String, T, Subscriber

## Knowledge Gaps
- **249 isolated node(s):** `PackageDescription`, `String`, `AutoMockable`, `AutoHashable`, `.unitTesting` (+244 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 460 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **4 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Foundation` connect `Foundation` to `ResponseHandlingApi`, `DownloadError`, `LoggerConfiguration`, `CSSBackgroundImage`, `ResponseType`, `CottonPluginError`, `CottonRestKit`, `DnsRR`, `Downloadable.swift`, `AutoMockable.swift`, `GoogleDNSEndpointError`, `AutoMockable`, `InstagramVideoNode`, `Combine+Extensions.swift`, `CapturingLogBackend`, `CottonBase`, `HTMLVideoTag`?**
  _High betweenness centrality (0.240) - this node is a cross-community bridge._
- **Why does `RestClient` connect `RestClient` to `.makeRequestFuture`, `.makeAuthorizedRequestProducer`, `ResponseType`, `.makeRxRequest`, `NetworkReachabilityAdapter`, `CottonRestKit`, `.makeRequest`, `.resolvedDomainName`, `Foundation`, `Sendable`, `AutoMockable`, `.makeRequestProducer`, `CottonBase`?**
  _High betweenness centrality (0.190) - this node is a cross-community bridge._
- **Why does `HttpError` connect `HttpError` to `AlamofireHTTPRxVoidAdaptee`, `RxObserverVoidWrapper`, `ResponseHandlingApi`, `ClosureVoidWrapper`, `AnyObject`, `.makeRxRequest`, `DnsError`, `.resolvedDomainName`, `GoogleDNSEndpointError`, `AlamofireHTTPAdaptee`, `ClosureWrapper`, `CottonBase`, `MockedHTTPAdapteeWithFail`?**
  _High betweenness centrality (0.185) - this node is a cross-community bridge._
- **What connects `PackageDescription`, `String`, `AutoMockable` to the rest of the system?**
  _249 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `AnyObject` be split into smaller, more focused modules?**
  _Cohesion score 0.054098360655737705 - nodes in this community are weakly interconnected._
- **Should `RxObserverVoidWrapper` be split into smaller, more focused modules?**
  _Cohesion score 0.053109713487071976 - nodes in this community are weakly interconnected._
- **Should `ResponseHandlingApi` be split into smaller, more focused modules?**
  _Cohesion score 0.060408163265306125 - nodes in this community are weakly interconnected._