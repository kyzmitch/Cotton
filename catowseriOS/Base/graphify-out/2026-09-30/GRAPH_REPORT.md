# Graph Report - Base  (2026-09-30)

## Corpus Check
- 104 files · ~34,205 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1039 nodes · 1780 edges · 67 communities (56 shown, 6 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 36 edges (avg confidence: 0.84)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `56667655`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- BaseJSHandler
- RxObserverVoidWrapper
- ResponseHandlingApi
- DownloadError
- .makeRequestProducer
- ResponseType
- Token
- DnsError
- CottonPluginError
- CottonRestKit
- HttpError
- Sendable
- DnsRR
- CottonBase
- Downloadable.swift
- JavaScriptEvaluateble
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
- NetworkReachabilityStatus
- ResponseVoidHandlingApi
- MockedHTTPAdapteeWithFail
- HTMLVideoTag
- package.json
- AlamofireHTTPRxVoidAdaptee
- ig.js
- ClosureVoidWrapper
- HttpClientTests
- LoggerConfiguration
- CSSBackgroundImage
- CottonLogger
- CodingKeys
- AlamofireReachabilityAdaptee
- .makeRequest
- HTMLContentMessage
- CodingKeys
- CottonRestKit/Extensions/HttpKotlinTypes+Extensions.swift
- .failure
- URL
- AutoMockable.swift
- Array
- Parser
- .init
- BaseTests.swift
- .init
- Combine+Extensions.swift
- Data
- README.md
- .startListening
- Package.swift
- .init
- HashType
- NumberType
- VideoFileNameble

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
- `.jsProgram` --calls--> `JSPluginsProgramImpl`  [INFERRED]
  catowseriOS/Base/Sources/CottonPlugins/JSPluginsBuilder.swift → catowseriOS/Base/Sources/CottonPlugins/JSPluginsProgramImpl.swift
- `.mainPosterURL` --calls--> `CSSBackgroundImage`  [INFERRED]
  catowseriOS/Base/Sources/CottonPlugins/Models/HTMLContentMessage.swift → catowseriOS/Base/Sources/CottonPlugins/Models/CSSModels/CSSBackgroundImage.swift
- `HttpClientTests` --calls--> `RestClient`  [INFERRED]
  catowseriOS/Base/Tests/CottonRestKitTests/HttpClientTests.swift → catowseriOS/Base/Sources/CottonRestKit/RestClient.swift
- `CottonLogger` --references--> `LogCategory`  [EXTRACTED]
  catowseriOS/Base/Sources/CottonLoggerKit/CottonLogger.swift → catowseriOS/Base/Sources/CottonLoggerKit/LogCategory.swift
- `CapturingLogBackend` --inherits--> `LogBackend`  [EXTRACTED]
  catowseriOS/Base/Tests/CottonLoggerKitTests/CottonLoggerKitTests.swift → catowseriOS/Base/Sources/CottonLoggerKit/LogBackend.swift

## Import Cycles
- None detected.

## Communities (67 total, 6 thin omitted)

### Community 0 - "BaseJSHandler"
Cohesion: 0.05
Nodes (44): Equatable, NSObject, Program, BaseJSHandler, MessageKey, DOMVideoTags, html, log (+36 more)

### Community 1 - "RxObserverVoidWrapper"
Cohesion: 0.06
Nodes (39): RR, HTTPRxAdapter, Endpoint, Response, Server, Signal, Void, Lifetime (+31 more)

### Community 2 - "ResponseHandlingApi"
Cohesion: 0.06
Nodes (35): ResponseApi, AlamofireHTTPRxAdaptee, Endpoint, Future, Int, ObserverWrapper, Response, Result (+27 more)

### Community 3 - "DownloadError"
Cohesion: 0.05
Nodes (39): LocalizedError, DownloadError, .errorDescription, failedCreateFileProviderFolder, failedExcludeFromBackup, networkError, noAppGroupDirectory, noContentLengthHeader (+31 more)

### Community 4 - ".makeRequestProducer"
Cohesion: 0.08
Nodes (32): RxSub, RxVoidProducer, RxVoidSubscriber, B, Endpoint, ResponseFuture, RX, RxProducer (+24 more)

### Community 5 - "ResponseType"
Cohesion: 0.05
Nodes (31): CGSearchPublisher, DDGoSuggestionsClientRxSubscriber, DDGoSuggestionsClientSubscriber, DDGoSuggestionsEndpoint, DDGoSuggestionsProducer, DDGoSuggestionsPublisher, GSearchClientRxSubscriber, GSearchClientSubscriber (+23 more)

### Community 6 - "Token"
Cohesion: 0.05
Nodes (36): Double, Int, String, Token, atKeyword, badString, badUrl, cdc (+28 more)

### Community 7 - "DnsError"
Cohesion: 0.07
Nodes (29): GDNSJsonClientRxSubscriber, GDNSJsonClientSubscriber, GDNSjsonProducer, GDNSjsonPublisher, ResolvedURLPublisher, AnyPublisher, ResolvedURLProducer, String (+21 more)

### Community 8 - "CottonPluginError"
Cohesion: 0.07
Nodes (26): Error, CottonPluginError, emptyHtml, .errorDescription, jsEvaluationIsNotString, jsEvaluationIsNotURL, jsFileNotFound, nilJSEvaluationResult (+18 more)

### Community 9 - "CottonRestKit"
Cohesion: 0.15
Nodes (8): Alamofire, Combine, CottonReactiveRestKit, CottonRestKit, ReactiveSwift, CottonBase.ServerDescription, String, HTTPRxVoidAdapter

### Community 10 - "HttpError"
Cohesion: 0.08
Nodes (25): HttpError, emptyQueryParam, failedConstructRequestParameters, failedEncodeEncodable, failedKotlinRequestConstruct, httpFailure, invalidDomainName, invalidURL (+17 more)

### Community 11 - "Sendable"
Cohesion: 0.10
Nodes (14): AnyObject, Sendable, ServerDescription, RestClientContext, DuckDuckGoServer, GoogleDnsServer, GoogleServer, JSPluginsProgram (+6 more)

### Community 12 - "DnsRR"
Cohesion: 0.11
Nodes (19): GDNSjsonEndpoint, GSearchEndpoint, RawRepresentable, DNSRecordType, addressRecord, canonicalName, .knownCase, Endpoint (+11 more)

### Community 13 - "CottonBase"
Cohesion: 0.15
Nodes (9): CottonBase, Foundation, Network, Security, Bool, WKScriptMessageHandler, JavaScriptPluginVisitor, DomainName.Error (+1 more)

### Community 14 - "Downloadable.swift"
Cohesion: 0.13
Nodes (18): CryptoKit, DownloadRequest, FileDownloadProducer, Progress, RemoteFileInfoProducer, download(), Downloadable, .excludeFromBackup (+10 more)

### Community 15 - "JavaScriptEvaluateble"
Cohesion: 0.18
Nodes (12): SecTrust, SignalProducer, DefaultTrustEvaluator, Self, String, JavaScriptEvaluateble, Any, AnyPublisher (+4 more)

### Community 16 - "AutoMockable"
Cohesion: 0.14
Nodes (13): AutoMockable, JSONEncoding, Any, String, URLRequest, JSONRequestEncodable, URLRequest, URLRequestCreatable (+5 more)

### Community 17 - "Scanner"
Cohesion: 0.23
Nodes (7): Scanner, .currentText, .isAtEnd, .peek1, .peek2, .peek3, String

### Community 18 - "ComponentValue"
Cohesion: 0.18
Nodes (18): AtRule, Category, descriptor, property, ComponentValue, function, preservedToken, simpleBlock (+10 more)

### Community 19 - "LogCategory"
Cohesion: 0.11
Nodes (16): LogCategory, coordinator, custom, downloads, featureFlags, general, networking, .osLogCategory (+8 more)

### Community 20 - "InstagramVideoNode"
Cohesion: 0.17
Nodes (12): CGSize, Decodable, CottonDummyDecodable, InstagramVideoArray, Decoder, IgEdgeMediaCaption, IgMediaCaptionEdge, IgMediaCaptionNodeText (+4 more)

### Community 21 - "CapturingLogBackend"
Cohesion: 0.27
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
Cohesion: 0.15
Nodes (9): E, CottonBase.ServerDescription, RestClient, String, Encoder, R, S, Server (+1 more)

### Community 26 - "ClosureWrapper"
Cohesion: 0.26
Nodes (11): Hashable, ClosureWrapper, CombinePromiseWrapper, Endpoint, Future, Hasher, Response, Result (+3 more)

### Community 27 - "NetworkReachabilityStatus"
Cohesion: 0.14
Nodes (13): Alamofire.NetworkReachabilityManager.NetworkReachabilityStatus, Alamofire.NetworkReachabilityManager.NetworkReachabilityStatus.ConnectionType, .httpKitValue, .httpKitValue, ConnectionType, cellular, ethernetOrWiFi, NetworkReachabilityStatus (+5 more)

### Community 28 - "ResponseVoidHandlingApi"
Cohesion: 0.15
Nodes (12): Observer, Server, ResponseVoidHandlingApi, asyncAwaitConcurrency, closure, combine, rxObserver, waitsForCombinePromise (+4 more)

### Community 29 - "MockedHTTPAdapteeWithFail"
Cohesion: 0.22
Nodes (10): MockedHTTPAdapteeWithFail, Endpoint, Future, Int, ObserverWrapper, Response, Result, Server (+2 more)

### Community 30 - "HTMLVideoTag"
Cohesion: 0.24
Nodes (8): Element, HTMLVideoTag, Decoder, Int, String, URL, HTMLVideoTagsContainer, SwiftSoup

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

### Community 35 - "HttpClientTests"
Cohesion: 0.17
Nodes (5): MockedGoodEndpoint, MockedGoodServer, HttpClientTests, MockedReachabilityAdaptee, Server

### Community 36 - "LoggerConfiguration"
Cohesion: 0.20
Nodes (7): os, LogBackend, LoggerConfiguration, .backend, .defaultMinimumLevel, .minimumLevel, SystemLogBackend

### Community 37 - "CSSBackgroundImage"
Cohesion: 0.18
Nodes (8): CottonPlugins, CssParser, CSSBackgroundImage, .firstURL, URL, CSSBackgroundImageTests, XCTest, XCTestCase

### Community 38 - "CottonLogger"
Cohesion: 0.53
Nodes (3): CottonLogger, Int, String

### Community 39 - "CodingKeys"
Cohesion: 0.20
Nodes (10): CodingKeys, displayUrl, isVideo, mediaCaption, mediaPreview, pageTitle, thumbnailSrc, typeName (+2 more)

### Community 40 - "AlamofireReachabilityAdaptee"
Cohesion: 0.25
Nodes (6): NetworkReachabilityManager, AlamofireReachabilityAdaptee, Bool, DispatchQueue, Listener, Server

### Community 41 - ".makeRequest"
Cohesion: 0.56
Nodes (5): B, Endpoint, Server, String, T

### Community 42 - "HTMLContentMessage"
Cohesion: 0.29
Nodes (7): HTMLContentMessage, .mainPosterURL, Decoder, URL, Document, .documentTitle, String

### Community 43 - "CodingKeys"
Cohesion: 0.29
Nodes (7): CodingKey, CodingKeys, hostname, htmlString, CodingKeys, poster, src

### Community 44 - "CottonRestKit/Extensions/HttpKotlinTypes+Extensions.swift"
Cohesion: 0.29
Nodes (6): HTTPRequestInfo, .urlRequest, Set, .dictionary, String, URLRequest

### Community 45 - ".failure"
Cohesion: 0.53
Nodes (4): Failure, Output, Combine.Future, Future

### Community 46 - "URL"
Cohesion: 0.33
Nodes (5): HostProducer, ResolvedURLProducer, String, URL, .rxHttpHost

### Community 47 - "AutoMockable.swift"
Cohesion: 0.33
Nodes (5): AutoHashable, AutoMockable, ProcessInfo, .unitTesting, Bool

### Community 48 - "Array"
Cohesion: 0.33
Nodes (5): Array, .kotlinArray, KotlinArray, .empty, URLQueryPair

### Community 49 - "Parser"
Cohesion: 0.33
Nodes (3): Parser, .current, .next

### Community 50 - ".init"
Cohesion: 0.40
Nodes (4): Reachability, Encoder, Server, TimeInterval

### Community 52 - ".init"
Cohesion: 0.50
Nodes (3): Client, HttpKitRxSubscriber, HttpKitSubscriber

### Community 55 - "README.md"
Cohesion: 0.50
Nodes (3): Initial setup was, Intallation, JavaScript info

### Community 56 - ".startListening"
Cohesion: 0.50
Nodes (3): Bool, DispatchQueue, Listener

### Community 60 - "HashType"
Cohesion: 0.67
Nodes (3): HashType, id, unrestricted

### Community 61 - "NumberType"
Cohesion: 0.67
Nodes (3): NumberType, integer, number

## Knowledge Gaps
- **250 isolated node(s):** `PackageDescription`, `String`, `AutoMockable`, `AutoHashable`, `.unitTesting` (+245 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 459 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **6 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Foundation` connect `CottonBase` to `BaseJSHandler`, `DownloadError`, `ResponseType`, `CottonPluginError`, `CottonRestKit`, `DnsRR`, `Downloadable.swift`, `AutoMockable`, `InstagramVideoNode`, `CapturingLogBackend`, `RestClient`, `HTMLVideoTag`, `HttpClientTests`, `LoggerConfiguration`, `CSSBackgroundImage`, `AutoMockable.swift`, `Combine+Extensions.swift`, `Data`, `VideoFileNameble`?**
  _High betweenness centrality (0.300) - this node is a cross-community bridge._
- **Why does `HttpError` connect `HttpError` to `AlamofireHTTPRxVoidAdaptee`, `RxObserverVoidWrapper`, `ResponseHandlingApi`, `ClosureVoidWrapper`, `BaseJSHandler`, `DownloadError`, `HttpClientTests`, `DnsError`, `DnsRR`, `CottonBase`, `AlamofireHTTPAdaptee`, `ClosureWrapper`, `MockedHTTPAdapteeWithFail`?**
  _High betweenness centrality (0.190) - this node is a cross-community bridge._
- **Why does `CottonBase` connect `CottonBase` to `BaseJSHandler`, `RxObserverVoidWrapper`, `ClosureVoidWrapper`, `HttpClientTests`, `DnsError`, `CottonRestKit`, `HTMLContentMessage`, `Sendable`, `CottonRestKit/Extensions/HttpKotlinTypes+Extensions.swift`, `Downloadable.swift`, `JavaScriptEvaluateble`, `Array`, `AutoMockable`, `RestClient`, `NetworkReachabilityStatus`?**
  _High betweenness centrality (0.189) - this node is a cross-community bridge._
- **What connects `PackageDescription`, `String`, `AutoMockable` to the rest of the system?**
  _250 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `BaseJSHandler` be split into smaller, more focused modules?**
  _Cohesion score 0.052083333333333336 - nodes in this community are weakly interconnected._
- **Should `RxObserverVoidWrapper` be split into smaller, more focused modules?**
  _Cohesion score 0.05520614954577219 - nodes in this community are weakly interconnected._
- **Should `ResponseHandlingApi` be split into smaller, more focused modules?**
  _Cohesion score 0.06382978723404255 - nodes in this community are weakly interconnected._