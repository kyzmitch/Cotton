# Graph Report - catowseriOS  (2026-09-03)

## Corpus Check
- 463 files · ~139,064 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 4398 nodes · 9122 edges · 266 communities (242 shown, 15 thin omitted)
- Extraction: 95% EXTRACTED · 5% INFERRED · 0% AMBIGUOUS · INFERRED: 453 edges (avg confidence: 0.82)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `564caea2`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- CottonViewModels
- WebViewController
- TabsDBClient
- RestClient
- Foundation
- CoreBrowser
- .makeRequestProducer
- AutoMockable
- TabViewModelImpl
- WebAutoCompletionSource
- TabsDataService
- AnyViewController
- DnsError
- BrowserToolbarController
- Sendable
- LinkTagsCoordinator
- Int
- SearchEngine
- ViewModelKit
- WebViewModelImpl
- Token
- ReplaceSelectedTabUseCase
- TabsViewController
- LayoutStep
- Bool
- BaseListViewModel
- FeatureManager
- UIServiceRegistry
- Tab
- SearchSuggestionsViewController
- SuggestionType
- AnyObject
- BrowserToolbarView
- TabView
- SearchSuggestionsResponse
- CoordinatorOwner
- TopSitesViewModel
- View
- SearchBarState
- TabsPreviewsError
- WebViewModelState
- Scanner
- ResponseVoidHandlingApi
- FilesGridCoordinator
- SearchBarCoordinator
- DummyRxType
- HttpError
- AppCoordinator
- StateHolder
- CodingKeys
- ResponseHandlingApi
- AddedTabPosition
- SearchBarViewModelImpl
- WebViewAction
- Error
- Equatable
- FilesGridViewController
- TabletView
- Database
- URLInfo
- Testing
- TabsServiceCommand
- RxObserverVoidWrapper
- UIFrameworkType
- UIImageView
- WebContentCoordinator
- TabsPreviewsViewController
- StateTransitioning
- ApplicationFeature
- SearchBarBaseViewController
- TopSitesViewController
- Coordinator
- SearchSuggestionsCoordinator
- MockedNavAction
- ApplicationEnumFeature
- ComponentValue
- TopSitesViewV2
- ImageSource
- LocalFeatureSource
- WebViewStateContextProxy
- HTMLContentMessage
- BrowserToolbarViewModelImpl
- BrowserMenuView
- SearchAutocompleteStrategy
- MockSearchStrategiesFactory
- SearchSuggestionsViewState
- SwiftUIMode
- LoadingProgressCoordinator
- ReusableItem
- UIImage
- TabPreviewCell
- TabsListError
- SearchBarAction
- LazyServiceLocator
- FakeTabStateContext
- ViewModelStateMachineTests.swift
- SearchBarLegacyView
- DownloadError
- DDGoSuggestionsResponse
- GSearchSuggestionsResponse
- JavaScriptEvaluateble
- .showNext
- .start
- BottomViewCoordinator
- DownloadButtonCellView
- SearchDataService
- SearchDataServiceProtocol
- TabletSearchBarViewController
- .source
- AlamofireHTTPAdaptee
- JSPluginsSource
- Hashable
- ObservingApiType
- ViewModelState
- SearchBarError
- GenericEnumFeature
- FakeSearchSuggestionsStateContext
- SwiftUIPreviewable
- DnsRR
- Character
- MainBrowserViewController
- MenuStatefullLabel
- State
- CounterView
- Trie
- ViewModelAction
- SearchBarViewV2
- AddTabUseCase
- AlamofireHTTPRxAdaptee
- JSPluginsBuilder
- ig.js
- package.json
- ClosureWrapper
- MockedHTTPAdapteeWithFail
- WebViewController
- WebViewControllerProxy
- LinkTagsViewController
- SearchSuggestionsListDelegate
- StateHolder
- GenericConcurrentDataService
- SearchSuggestionsVMTestFixture
- FakeWebViewStateContext
- SearchFieldView
- Theme
- NetworkReachabilityStatus
- .resolvedDomainName
- AlamofireHTTPRxVoidAdaptee
- HTMLVideoTag
- WebViewNavigatable
- .collectionView
- DisableableButton
- SearchServiceData
- SearchBarDelegateImpl
- BrowserToolbarState
- CommandExecutionData
- MockReplaceSelectedTabUseCase
- .present
- FakeSearchViewContext
- Downloadable
- FileDownloadViewModel
- GoogleDNSEndpointError
- CottonPluginError
- MessageKey
- BaseViewController
- ThemeProvider
- ObservableObject
- ClearCancelButtonViewModel
- GoogleDNSOverJSONResponse
- CottonRestKit/Extensions/HttpKotlinTypes+Extensions.swift
- DownloadState
- .insert
- Site
- SearchServiceError
- TabsPreviewState
- TabStateContextProxy
- BrowserToolbarAction
- WebViewVMFixture
- .evaluateJavaScriptV2
- GDNSRequestParams
- .makeRequest
- AppDelegate
- UIViewController
- Box
- BrowserToolbarViewContextImpl
- HTMLVideoTag
- CottonMenuItem
- SuggestionRowView
- .init
- AppError
- SearchBarStateContext
- SearchSuggestionsStateContext
- TabAction
- StateHolder
- DataServiceLocator
- BaseViewModel
- .transferToRxState
- TabViewContextImpl
- MainScreenSubview
- .insertNext
- LinksBadgeView
- PhoneSearchBarLegacyView
- TabletSearchBarLegacyView
- SearchSuggestionsLegacyView
- TabletTabsLegacyView
- .makeTask
- StateContext
- .evaluateJavaScriptV2
- FeatureManager.StateHolder
- MenuButton
- PackageDescription
- AlamofireReachabilityAdaptee
- DispatchQueue
- MainScreenRoute
- ContentCoordinatorsInterface
- TrieNode
- String
- URL
- SearchBarInViewMode
- Error
- TopSitesStateTransitioningTests
- UIConstants.swift
- .aaGetIPaddress
- .evaluateWithRecovery
- .script
- CSSBackgroundImage
- URL
- .failure
- Parser
- .handleTabSelection
- DownloadButtonState
- ReloadWithCompletion.swift
- ViewModelInterface
- .read
- MockedJSPluginsProgram
- MockFetchAutocompleteSuggestionsUseCase
- ProgressResponse
- InstagramVideoArray
- .init
- .tableView
- .findDataService
- .subscript
- LeadingTrimmed
- ImmediateDispatchQueue
- MockCreateSearchURLUseCase
- Database.swift
- README.md
- Combine+Extensions.swift
- .isSimilar
- Weak
- SearchBarStateTransitioning
- HashType
- NumberType
- NavigationActionable
- Site.Settings
- DataServiceFactory
- .init
- WebViewVmDNSoverHTTPSConcurrencyTests

## God Nodes (most connected - your core abstractions)
1. `CoreBrowser` - 232 edges
2. `CottonBase` - 135 edges
3. `AppCoordinator` - 91 edges
4. `CottonViewModels` - 83 edges
5. `AnyViewController` - 79 edges
6. `HttpError` - 67 edges
7. `RestClient` - 59 edges
8. `FeatureFlagsKit` - 56 edges
9. `UIFrameworkType` - 54 edges
10. `Token` - 53 edges

## Surprising Connections (you probably didn't know these)
- `MainBrowserViewModel` --calls--> `JSPluginsBuilder`  [INFERRED]
  catowser/Browser/View/MainBrowserViewModel.swift → Base/Sources/CottonPlugins/JSPluginsBuilder.swift
- `.tabsSubject` --calls--> `TabsDataSubject`  [EXTRACTED]
  catowser/ServiceRegistry/UIServiceRegistry.swift → Domain/Sources/CottonTabs/TabsDataSubject.swift
- `.body` --references--> `BaseListViewModel`  [INFERRED]
  catowser/Menu/BaseMenuView.swift → Domain/Sources/CottonViewModels/BaseListViewModel.swift
- `.body` --references--> `SearchSuggestionsListDelegate`  [INFERRED]
  catowser/SearchSuggestions/SearchSuggestionsViewV2.swift → Domain/Sources/CottonViewModels/SearchBarViewModel/SearchSuggestionsListDelegate.swift
- `.previews` --calls--> `SearchBarStateTransitioning`  [INFERRED]
  Presentation/Sources/SearchViews/Phone/SearchBarViewV2.swift → Domain/Sources/CottonViewModels/SearchBarViewModel/States/SearchBarState.swift

## Import Cycles
- None detected.

## Communities (266 total, 15 thin omitted)

### Community 0 - "CottonViewModels"
Cohesion: 0.05
Nodes (23): AlamofireImage, BottomViewPart, SubviewPart, FilesGridPart, LinkTagsPart, filesGrid, LoadingProgressPart, ToolbarPart (+15 more)

### Community 1 - "WebViewController"
Cohesion: 0.05
Nodes (42): AuthHandler, Set, .dictionary, String, WebViewReusable, Hasher, MainActor, SecTrust (+34 more)

### Community 2 - "TabsDBClient"
Cohesion: 0.05
Nodes (33): CDAppSettings, CDSite, CDSiteSettings, CDTab, CoreBrowser.Tab, Site, Site.Settings, NSManagedObjectContext (+25 more)

### Community 3 - "RestClient"
Cohesion: 0.06
Nodes (17): Alamofire, String, HTTPRxVoidAdapter, RestClient, String, E, Encoder, R (+9 more)

### Community 4 - "Foundation"
Cohesion: 0.06
Nodes (15): String, RestInterface, CSSBackgroundImageTests, CollectionViewSizes, CottonBase, CottonNetworking, CottonPlugins, String (+7 more)

### Community 5 - "CoreBrowser"
Cohesion: 0.07
Nodes (20): ImageViewSizes, CGFloat, TabPreviewsContextImpl, .contentState, String, String, CoreBrowser, CoreGraphics (+12 more)

### Community 6 - ".makeRequestProducer"
Cohesion: 0.06
Nodes (40): B, Endpoint, ResponseFuture, RX, RxProducer, RxSubscriber, Server, String (+32 more)

### Community 7 - "AutoMockable"
Cohesion: 0.07
Nodes (22): AutoMockable, NetworkReachabilityAdapter, Server, BaseUseCaseKit, TabsDataServiceProtocol, IndexSelectionContext, TabsStatesInterface, AddTabUseCaseImpl (+14 more)

### Community 8 - "TabViewModelImpl"
Cohesion: 0.07
Nodes (27): CoreUseCase, TabsDataSubject, .tabsCount, CloseTabUseCase, ReadAllTabsUseCase, ReadAllTabsUseCaseImpl, Void, ReadSelectedTabIdUseCase (+19 more)

### Community 9 - "WebAutoCompletionSource"
Cohesion: 0.04
Nodes (44): CaseIterable, SearchViewContextImpl, .appAsyncApiTypeValue, .knownDomainsStorage, .webAutocompletionSourceValue, LinksType, audio, .description (+36 more)

### Community 10 - "TabsDataService"
Cohesion: 0.09
Nodes (23): AddTabData, AllTabsData, CloseAllTabsData, CloseTabData, Array, Command, ServiceData, TabsDataService (+15 more)

### Community 11 - "AnyViewController"
Cohesion: 0.07
Nodes (25): BlankContentCoordinator, R, UINavigationController, UIView, Navigating, R, PhoneTabsCoordinator, TabsPreviewsViewModelWithHolder (+17 more)

### Community 12 - "DnsError"
Cohesion: 0.06
Nodes (34): DnsError, .errorDescription, failToGetUrlFromComponents, hostIsNotIpAddress, httpError, noHost, notHttpScheme, urlComponentsFail (+26 more)

### Community 13 - "BrowserToolbarController"
Cohesion: 0.06
Nodes (22): DummyDelegate, PhoneViewControllerFactory, .blankWebPageViewController, .createdDeviceSpecificSearchBarVC, .createdToolbaViewController, AllTabsViewModel, C, SearchBarViewModel (+14 more)

### Community 14 - "Sendable"
Cohesion: 0.06
Nodes (30): CottonBase.ServerDescription, RestClientContext, Client, HttpKitRxSubscriber, HttpKitSubscriber, JSONEncoding, Any, String (+22 more)

### Community 15 - "LinkTagsCoordinator"
Cohesion: 0.08
Nodes (19): LinkTagsCoordinator, LinkTagsRoute, closeTags, openHtmlTags, openInstagramTags, CGFloat, CGRect, HTMLVideoTag (+11 more)

### Community 16 - "Int"
Cohesion: 0.09
Nodes (15): VoidResponse, .successCodes, ResponseType, .successCodes, MockedGoodEndpointResponse, .successCodes, BrowserContentViewModel, Void (+7 more)

### Community 17 - "SearchEngine"
Cohesion: 0.07
Nodes (29): Description, OpenSearch, Error, htmlTemplateUrlNotFound, noAnyURLXml, noTemplateParameter, notImplementedHttpMethod, notValidURL (+21 more)

### Community 18 - "ViewModelKit"
Cohesion: 0.06
Nodes (11): CottonDependencyAssembly, CottonUseCases, AllTabsAction, addTab, .allCases, UIColor, TopSitesAction, .allCases (+3 more)

### Community 19 - "WebViewModelImpl"
Cohesion: 0.09
Nodes (23): Action, Context, Error, Site, String, Task, URL, Void (+15 more)

### Community 20 - "Token"
Cohesion: 0.06
Nodes (35): Double, String, Token, atKeyword, badString, badUrl, cdc, cdo (+27 more)

### Community 21 - "ReplaceSelectedTabUseCase"
Cohesion: 0.09
Nodes (18): AllTabsViewModel, SearchBarViewModelWithDelegates, Site, TabsPreviewsViewModelWithHolder, ViewModelFactory, UseCaseRegistry, DefaultTabProvider, CreateSearchURLUseCase (+10 more)

### Community 22 - "TabsViewController"
Cohesion: 0.10
Nodes (12): Sizes, AllTabsViewModel, CGFloat, CGRect, CGSize, NSCoder, UIButton, UITraitCollection (+4 more)

### Community 23 - "LayoutStep"
Cohesion: 0.07
Nodes (22): Layouting, LayoutStep, viewDidLayoutSubviews, viewDidLoad, viewSafeAreaInsetsDidChange, OwnLayoutStep, viewDidLayoutSubviews, viewDidLoad (+14 more)

### Community 24 - "Bool"
Cohesion: 0.09
Nodes (20): Context, Site, UIViewControllerType, W, WebView, .body, WebViewLegacyView, Site (+12 more)

### Community 25 - "BaseListViewModel"
Cohesion: 0.07
Nodes (20): EnumDataSourceType, PopClosure, EnumDataSourceType, PopClosure, BaseMenuView, .body, EnumDataSourceType, PopClosure (+12 more)

### Community 26 - "FeatureManager"
Cohesion: 0.11
Nodes (19): SearchBarContextImpl, .blockPopups, .isJSEnabled, .webAutocompletionSourceValue, .body, BrowserMenuStyle, onlyGlobalMenu, withSiteMenu (+11 more)

### Community 27 - "UIServiceRegistry"
Cohesion: 0.08
Nodes (19): AllTabsViewModel, C, SearchBarViewModel, TabsPreviewsViewModelWithHolder, UISearchBarDelegate, UIViewController, TabletViewControllerFactory, .blankWebPageViewController (+11 more)

### Community 28 - "Tab"
Cohesion: 0.09
Nodes (22): UUID, Date, ContentType, blank, favorites, homepage, .isStatic, .rawValue (+14 more)

### Community 29 - "SearchSuggestionsViewController"
Cohesion: 0.09
Nodes (17): SearchBarPart, simplySuggestions, suggestions, SearchSuggestionsViewModel, String, SearchSuggestionsControllerInterface, SearchSuggestionsViewController, .state (+9 more)

### Community 30 - "SuggestionType"
Cohesion: 0.08
Nodes (10): SuggestionType, knownDomain, looksLikeURL, suggestion, String, RecordingError, intentional, RecordingSearchBarStateContext (+2 more)

### Community 31 - "AnyObject"
Cohesion: 0.11
Nodes (18): AnyObject, BaseJSHandler, Any, InstagramHandler, WKScriptMessage, BasePluginContentDelegate, InstagramContentDelegate, PluginHandlerDelegateType (+10 more)

### Community 32 - "BrowserToolbarView"
Cohesion: 0.11
Nodes (16): BrowserToolbarView, .downloadsViewHidden, .enableDownloadsButton, .state, CGRect, NSCoder, UIBarButtonItem, WebToolbarState (+8 more)

### Community 33 - "TabView"
Cohesion: 0.11
Nodes (15): ButtonWithDecreasedTouchArea, AnyCancellable, CGPoint, CGRect, CGSize, NSCoder, UIEvent, UILabel (+7 more)

### Community 34 - "SearchSuggestionsResponse"
Cohesion: 0.12
Nodes (16): SearchSuggestionsResponse, String, DDGoAutocompleteStrategy, AnyPublisher, Context, SignalProducer, String, GoogleAutocompleteStrategy (+8 more)

### Community 35 - "CoordinatorOwner"
Cohesion: 0.08
Nodes (20): BlankContentRoute, CoordinatorOwner, Route, GlobalMenuCoordinator, MenuScreenRoute, CGRect, R, UINavigationController (+12 more)

### Community 36 - "TopSitesViewModel"
Cohesion: 0.12
Nodes (20): MainBrowserV2ViewController, AllTabsViewModel, C, NSCoder, S, SB, W, MainBrowserView (+12 more)

### Community 37 - "View"
Cohesion: 0.09
Nodes (25): .uiKitWrapperView, SiteMenuView_Previews, Content, AppAsyncApiTypeView_Previews, .previews, View, View, TabAddPositionsView_Previews (+17 more)

### Community 38 - "SearchBarState"
Cohesion: 0.10
Nodes (18): SearchBarInSearchMode, .modeHandler, .showCancelButton, C, String, SearchBarInSearchModeHandler, SearchBarInvalidModeHandler, SearchBarInViewModeHandler (+10 more)

### Community 39 - "TabsPreviewsError"
Cohesion: 0.10
Nodes (15): Error, String, TabsPreviewsError, .errorDescription, failToLoad, nilStateContext, notImplementedYet, tabsNotLoadedToClose (+7 more)

### Community 40 - "WebViewModelState"
Cohesion: 0.08
Nodes (24): BaseState, Site, String, URL, WebViewModelState, checkingDNResolveSupport, creatingRequest, .description (+16 more)

### Community 41 - "Scanner"
Cohesion: 0.19
Nodes (8): String, Scanner, .currentText, .isAtEnd, .peek1, .peek2, .peek3, String

### Community 42 - "ResponseVoidHandlingApi"
Cohesion: 0.11
Nodes (17): ClientRxSubscriber, ClientRxVoidSubscriber, R, RX, S, Observer, Server, ResponseVoidHandlingApi (+9 more)

### Community 43 - "FilesGridCoordinator"
Cohesion: 0.12
Nodes (14): FilesGridCoordinator, FilesGridRoute, clear, hide, show, CGFloat, CGRect, NSLayoutConstraint (+6 more)

### Community 44 - "SearchBarCoordinator"
Cohesion: 0.15
Nodes (13): SearchBarCoordinator, SearchBarDelegate, SearchBarRoute, handleAction, hideSuggestions, suggestions, NSRange, R (+5 more)

### Community 45 - "DummyRxType"
Cohesion: 0.09
Nodes (17): Signal.Observer, Response, DummyRxLifetime, DummyRxObserver, DummyRxType, .endpoint, .lifetime, .observer (+9 more)

### Community 46 - "HttpError"
Cohesion: 0.08
Nodes (24): HttpError, emptyQueryParam, failedConstructRequestParameters, failedEncodeEncodable, failedKotlinRequestConstruct, httpFailure, invalidDomainName, invalidURL (+16 more)

### Community 47 - "AppCoordinator"
Cohesion: 0.16
Nodes (9): AppCoordinator, .globalMenuDelegate, .navigationComponent, .siteNavigator, .toolbarPresenter, .uiFramework, FullSiteNavigationComponent, UINavigationController (+1 more)

### Community 48 - "StateHolder"
Cohesion: 0.11
Nodes (15): DuckDuckGoServer, GoogleDnsServer, GoogleServer, MockedGoodServer, StateHolder, DDGoSuggestionsClientRxSubscriber, DDGoSuggestionsClientSubscriber, GDNSJsonClientRxSubscriber (+7 more)

### Community 49 - "CodingKeys"
Cohesion: 0.11
Nodes (20): CottonDummyDecodable, CodingKeys, displayUrl, isVideo, mediaCaption, mediaPreview, pageTitle, thumbnailSrc (+12 more)

### Community 50 - "ResponseHandlingApi"
Cohesion: 0.11
Nodes (21): HTTPAdapter, init(), ObserverWrapper, Response, RxFreeDummy, Server, ResponseHandlingApi, asyncAwaitConcurrency (+13 more)

### Community 51 - "AddedTabPosition"
Cohesion: 0.09
Nodes (22): .description, .id, RawValue, String, StateHolder, .addPosition, .addSpeed, .contentState (+14 more)

### Community 52 - "SearchBarViewModelImpl"
Cohesion: 0.27
Nodes (8): SearchBarViewModelImpl, .context, .searchSuggestionsDelegate, Context, UISearchBarDelegate, SearchBarViewModelImplTests, SearchBarVMFixture, SearchBarViewModelWithDelegates

### Community 53 - "WebViewAction"
Cohesion: 0.09
Nodes (23): Site, URL, WebViewAction, .allCases, changeDoH, changeJavaScript, checkDNResolvingSupport, createRequestAnyway (+15 more)

### Community 54 - "Error"
Cohesion: 0.09
Nodes (20): DecodingError, missingPreviewURL, notVideo, wrongBase64String, wrongDataForImage, CssParseError, failConvertStringToDouble, DbError (+12 more)

### Community 55 - "Equatable"
Cohesion: 0.14
Nodes (15): BasePlugin, String, InstagramContentPlugin, String, JavaScriptPlugin, WKScriptMessageHandler, JavaScriptPluginVisitor, String (+7 more)

### Community 56 - "FilesGridViewController"
Cohesion: 0.10
Nodes (13): HTMLVideoTag, InstagramVideoNode, TagsSiteDataSource, htmlVideos, instagram, .itemsCount, FilesGridViewController, Sizes (+5 more)

### Community 57 - "TabletView"
Cohesion: 0.13
Nodes (20): .body, PhoneView, .body, .menuModel, BrowserToolbarViewModel, S, SB, String (+12 more)

### Community 58 - "Database"
Cohesion: 0.14
Nodes (11): Database, .storeURL, .viewContext, NSManagedObjectContext, String, URL, Void, .shared (+3 more)

### Community 59 - "URLInfo"
Cohesion: 0.14
Nodes (10): URL, URLRequest, URLInfo, .platformURL, .urlRequest, .urlWithResolvedDomainName, Site, Settings (+2 more)

### Community 60 - "Testing"
Cohesion: 0.10
Nodes (6): Base, Domain, AllTabsStateTransitioningTests, RecordingAllTabsContext, SearchSuggestionsViewStateTests, Testing

### Community 61 - "TabsServiceCommand"
Cohesion: 0.10
Nodes (16): Data, Any, TabsServiceCommand, addTab, closeAll, closeTab, closeTabWithId, getAllTabs (+8 more)

### Community 62 - "RxObserverVoidWrapper"
Cohesion: 0.17
Nodes (16): Lifetime, RxObserverVoidWrapper, .lifetime, .observer, RxObserverWrapper, .lifetime, .observer, Endpoint (+8 more)

### Community 63 - "UIFrameworkType"
Cohesion: 0.10
Nodes (18): .swiftUIMode, AllTabsViewModel, S, SB, W, RawValue, String, .description (+10 more)

### Community 64 - "UIImageView"
Cohesion: 0.11
Nodes (13): BlankWebPageViewController, SiteCollectionViewCell, CGRect, NSCoder, Site, UILabel, .mediaFilePreviewURL, URL (+5 more)

### Community 65 - "WebContentCoordinator"
Cohesion: 0.12
Nodes (10): Float, R, Site, String, UINavigationController, UIView, WebContentCoordinator, .siteNavigationDelegate (+2 more)

### Community 66 - "TabsPreviewsViewController"
Cohesion: 0.12
Nodes (13): AnyCancellable, C, NSCoder, TabsPreviewsViewModel, UIBarButtonItem, UIToolbar, TabsPreviewsViewController, .prefersStatusBarHidden (+5 more)

### Community 67 - "StateTransitioning"
Cohesion: 0.10
Nodes (7): SearchSuggestionsStateTransitioning, TabStateTransitioning, TopSitesStateTransitioning, WebViewStateTransitioning, ClosureStateTransitioning, StateTransitioning, Transition

### Community 68 - "ApplicationFeature"
Cohesion: 0.14
Nodes (17): .dnsOverHTTPSAvailable, .javaScriptEnabled, .nativeAppRedirect, DoHAvailable, JavaScriptEnabled, NativeAppRedirect, String, BasicFeature (+9 more)

### Community 69 - "SearchBarBaseViewController"
Cohesion: 0.14
Nodes (9): SmartphoneSearchBarViewController, NSCoder, UIView, SearchBarBaseViewController, SearchBarControllerInterface, NSCoder, SearchBarViewModel, UISearchBarDelegate (+1 more)

### Community 70 - "TopSitesViewController"
Cohesion: 0.11
Nodes (15): CGSize, UITraitCollection, Bundle, C, CGSize, IndexPath, NSCoder, String (+7 more)

### Community 71 - "Coordinator"
Cohesion: 0.13
Nodes (10): Coordinator, .isPad, .startedView, UIView, MainToolbarCoordinator, NSLayoutYAxisAnchor, R, SP (+2 more)

### Community 72 - "SearchSuggestionsCoordinator"
Cohesion: 0.14
Nodes (11): SearchSuggestionsCoordinator, .keyboardHeight, SearchSuggestionsRoute, startSearch, CGFloat, MainActor, NSLayoutYAxisAnchor, Sendable (+3 more)

### Community 73 - "MockedNavAction"
Cohesion: 0.14
Nodes (9): MockedNavAction, URL, URLRequest, T, TimeInterval, WebViewVMConcurrencyTests, StaticString, UInt (+1 more)

### Community 74 - "ApplicationEnumFeature"
Cohesion: 0.14
Nodes (17): AppAsyncApiFeature, .appDefaultAsyncApi, .observingApi, .tabAddPosition, .tabDefaultContent, .webAutoCompletionSource, EnumFeaturesHolder, ApplicationEnumFeature (+9 more)

### Community 75 - "ComponentValue"
Cohesion: 0.18
Nodes (18): AtRule, Category, descriptor, property, ComponentValue, function, preservedToken, simpleBlock (+10 more)

### Community 76 - "TopSitesViewV2"
Cohesion: 0.12
Nodes (13): Binding, Site, URL, TitledImageView, .body, Context, UIViewControllerType, TopSitesLegacyView (+5 more)

### Community 77 - "ImageSource"
Cohesion: 0.18
Nodes (13): Error, .errorDescription, missingContext, ImageSource, image, url, urlWithPlaceholder, BaseState (+5 more)

### Community 78 - "LocalFeatureSource"
Cohesion: 0.17
Nodes (11): LocalFeatureSource, .futureFeatureChanges, .rxFutureFeatureChanges, String, AnyPublisher, F, Never, Signal (+3 more)

### Community 79 - "WebViewStateContextProxy"
Cohesion: 0.12
Nodes (10): JSPluginsProgram, Site, String, URL, WKWebViewConfiguration, WebViewStateContext, WebViewStateContextProxy, .isDohEnabled (+2 more)

### Community 80 - "HTMLContentMessage"
Cohesion: 0.13
Nodes (14): CodingKeys, hostname, htmlString, HTMLContentMessage, .mainPosterURL, Decoder, URL, Document (+6 more)

### Community 81 - "BrowserToolbarViewModelImpl"
Cohesion: 0.15
Nodes (9): BrowserToolbarViewModel, BrowserToolbarViewModelImpl, .context, .siteExternalDelegate, .siteNavigationDelegate, Action, Context, Float (+1 more)

### Community 82 - "BrowserMenuView"
Cohesion: 0.14
Nodes (10): .fullySwiftUIView, UIHostingController, BrowserMenuView, .previews, SiteMenuViewController, C, NSCoder, Context (+2 more)

### Community 83 - "SearchAutocompleteStrategy"
Cohesion: 0.16
Nodes (10): StrategyFactory, SearchAutocompleteStrategy, DDGoContext, Client, HttpKitRxSubscriber, HttpKitSubscriber, GoogleContext, Client (+2 more)

### Community 84 - "MockSearchStrategiesFactory"
Cohesion: 0.21
Nodes (9): SearchServiceCommand, .allCases, fetchAutocompleteSuggestions, fetchSearchURL, resolveDomainNameInURL, String, URL, MockSearchStrategiesFactory (+1 more)

### Community 85 - "SearchSuggestionsViewState"
Cohesion: 0.12
Nodes (14): Error, .errorDescription, missingContext, unexpectedStateForAction, SearchSuggestionsViewState, everythingLoaded, knownDomainsLoaded, .sectionsNumber (+6 more)

### Community 86 - "SwiftUIMode"
Cohesion: 0.18
Nodes (12): SwiftUIMode, compatible, full, .fullySwiftUIView, .uiKitWrapperView, BrowserContentView, .body, Binding (+4 more)

### Community 87 - "LoadingProgressCoordinator"
Cohesion: 0.13
Nodes (10): LoadingProgressCoordinator, LoadingProgressRoute, setProgress, showProgress, Float, NSLayoutConstraint, NSLayoutYAxisAnchor, R (+2 more)

### Community 88 - "ReusableItem"
Cohesion: 0.22
Nodes (8): ReusableItem, .reuseID, IndexPath, String, View, UICollectionView, UITableView, Cell

### Community 89 - "UIImage"
Cohesion: 0.19
Nodes (12): CoreBrowser.Tab, .preview, CIImage, CoreImage, CGImage, CGFloat, CGPoint, CGSize (+4 more)

### Community 90 - "TabPreviewCell"
Cohesion: 0.17
Nodes (12): FaviconImageViewable, Site, CGFloat, UIButton, UILabel, UITraitCollection, UIView, TabPreviewCell (+4 more)

### Community 91 - "TabsListError"
Cohesion: 0.12
Nodes (16): NSError, String, TabsListError, closingNonExistingTab, .errorDescription, failToAddDefaultTab, failToFindNewSelectedTab, failToRemoveTab (+8 more)

### Community 92 - "SearchBarAction"
Cohesion: 0.14
Nodes (13): SearchBarAction, cancelSearch, clearView, selectSuggestion, startSearch, updateView, String, Binding (+5 more)

### Community 93 - "LazyServiceLocator"
Cohesion: 0.20
Nodes (9): LazyServiceLocator, ServiceRecord, fromClosure, instance, Any, String, T, ServiceLocator (+1 more)

### Community 94 - "FakeTabStateContext"
Cohesion: 0.18
Nodes (5): FakeTabStateContext, SelectionFailure, Error, String, TabStateTransitioningTests

### Community 95 - "ViewModelStateMachineTests.swift"
Cohesion: 0.23
Nodes (10): BaseViewModelStateMachineTests, expectSendAction(), IncrementTransitioning, Void, TestAction, .allCases, fail, increment (+2 more)

### Community 96 - "SearchBarLegacyView"
Cohesion: 0.18
Nodes (9): SearchBarLegacyView, .delegate, AnyCancellable, NSLayoutConstraint, String, UILabel, UISearchBar, UISearchBarDelegate (+1 more)

### Community 97 - "DownloadError"
Cohesion: 0.12
Nodes (15): DownloadError, .errorDescription, failedCreateFileProviderFolder, failedExcludeFromBackup, networkError, noAppGroupDirectory, noContentLengthHeader, noCorrectDownloadDestination (+7 more)

### Community 98 - "DDGoSuggestionsResponse"
Cohesion: 0.13
Nodes (11): String, DDGoSuggestionsResponse, .successCodes, Endpoint, DDGoSuggestionsClientRxSubscriber, DDGoSuggestionsClientSubscriber, Decoder, String (+3 more)

### Community 99 - "GSearchSuggestionsResponse"
Cohesion: 0.14
Nodes (11): String, Endpoint, GSearchSuggestionsResponse, .successCodes, Decoder, GSearchClientRxSubscriber, GSearchClientSubscriber, String (+3 more)

### Community 100 - "JavaScriptEvaluateble"
Cohesion: 0.30
Nodes (8): JavaScriptEvaluateble, Any, AnyPublisher, Error, SignalProducer, String, URL, Void

### Community 101 - ".showNext"
Cohesion: 0.14
Nodes (5): Float, Host, HTMLVideoTag, InstagramVideoNode, R

### Community 103 - "BottomViewCoordinator"
Cohesion: 0.15
Nodes (9): BottomViewCoordinator, .startedView, .underToolbarViewBounds, CGRect, NSLayoutConstraint, NSLayoutYAxisAnchor, SP, UINavigationController (+1 more)

### Community 104 - "DownloadButtonCellView"
Cohesion: 0.16
Nodes (12): FileDownloadViewDelegate, DownloadButtonCellView, .buttonState, .downloadButton, .previewImageView, .viewModel, Disposable, UIButton (+4 more)

### Community 105 - "SearchDataService"
Cohesion: 0.24
Nodes (9): SearchDataService, SearchStrategiesFactoryProtocol, AnyCancellable, Command, Result, ServiceData, ServiceError, String (+1 more)

### Community 106 - "SearchDataServiceProtocol"
Cohesion: 0.17
Nodes (9): SearchDataServiceProtocol, CreateSearchURLUseCaseImpl, Input, Output, FetchAutocompleteSuggestionsUseCaseImpl, Input, Output, ResolveDNSUseCaseImpl (+1 more)

### Community 107 - "TabletSearchBarViewController"
Cohesion: 0.16
Nodes (7): CGRect, UIButton, UIView, TabletSearchBarViewController, .downloadsPopoverStartInfo, .siteNavigator, .webViewInterface

### Community 108 - ".source"
Cohesion: 0.26
Nodes (7): AppFeaturePublisher, StateHolder, F, Never, Signal, String, EnumFeatureSource

### Community 109 - "AlamofireHTTPAdaptee"
Cohesion: 0.23
Nodes (9): AlamofireHTTPAdaptee, Endpoint, Future, Response, Result, RxFreeDummy, Server, URLRequest (+1 more)

### Community 110 - "JSPluginsSource"
Cohesion: 0.14
Nodes (8): JSPluginsSource, DomainNativeAppChecker, Host, String, Host, String, WebViewContextImpl, .isDohEnabled

### Community 111 - "Hashable"
Cohesion: 0.25
Nodes (11): ClosureVoidWrapper, CombinePromiseVoidWrapper, Endpoint, Future, Hasher, Result, Server, Void (+3 more)

### Community 112 - "ObservingApiType"
Cohesion: 0.17
Nodes (13): .description, .id, RawValue, String, AppStartInfo, AllTabsViewModel, SearchBarViewModelWithDelegates, TabsPreviewsViewModelWithHolder (+5 more)

### Community 113 - "ViewModelState"
Cohesion: 0.14
Nodes (7): AllTabsState, AllTabsStateTransitioning, BaseState, BaseState, Site, TopSitesViewState, ViewModelState

### Community 114 - "SearchBarError"
Cohesion: 0.13
Nodes (12): SearchBarError, alreadyInSearchMode, cannotCancelSearchWhenInViewMode, cannotSeeSuggestionsInViewMode, .errorDescription, failToCreatUrlFromDomain, failToInitNewSiteValue, invalidDummyState (+4 more)

### Community 115 - "GenericEnumFeature"
Cohesion: 0.14
Nodes (12): .defaultEnumValue, EnumFeature, .description, .name, .source, String, GenericEnumFeature, .defaultEnumValue (+4 more)

### Community 116 - "FakeSearchSuggestionsStateContext"
Cohesion: 0.23
Nodes (7): FakeSearchSuggestionsStateContext, SearchSuggestionsStateTransitioningTests, SoftFailError, Error, KnownDomains, QuerySuggestions, String

### Community 117 - "SwiftUIPreviewable"
Cohesion: 0.16
Nodes (9): AutoHashable, AutoMockable, ProcessInfo, .unitTesting, UIView, SwiftUIPreviewable, .isPreviewingSwiftUI, UIView (+1 more)

### Community 118 - "DnsRR"
Cohesion: 0.21
Nodes (10): Answer, DNSRecordType, addressRecord, canonicalName, .knownCase, DnsRR, String, UInt32 (+2 more)

### Community 119 - "Character"
Cohesion: 0.14
Nodes (13): Character, .isDigit, .isHexDigit, .isLetter, .isLowercase, .isMaximumAllowed, .isName, .isNameStart (+5 more)

### Community 120 - "MainBrowserViewController"
Cohesion: 0.15
Nodes (7): MainBrowserViewController, .preferredStatusBarStyle, C, NSCoder, UIEvent, UIStatusBarStyle, UITouch

### Community 121 - "MenuStatefullLabel"
Cohesion: 0.19
Nodes (9): ResignKeyboardOnDragGesture, Content, View, .isPad, AlignTextRight, MenuStatefullLabel, .body, String (+1 more)

### Community 122 - "State"
Cohesion: 0.27
Nodes (4): State, Action, ViewModelStateMachine, ViewModelStateMachineTests

### Community 123 - "CounterView"
Cohesion: 0.14
Nodes (11): CGPoint, UIEvent, UIView, CounterView, .digit, CGPoint, CGRect, NSCoder (+3 more)

### Community 124 - "Trie"
Cohesion: 0.33
Nodes (6): String, Trie, .count, .isEmpty, .words, Node

### Community 125 - "ViewModelAction"
Cohesion: 0.14
Nodes (12): SearchSuggestionsAction, .allCases, loadKnownDomains, loadSuggestions, String, TabsPreviewsAction, addDefaultTab, closeTab (+4 more)

### Community 126 - "SearchBarViewV2"
Cohesion: 0.21
Nodes (10): CustomHStackStyle, SearchBarViewV2, SearchBarViewV2_Previews, .previews, Binding, CGFloat, Content, SearchBarViewModel (+2 more)

### Community 127 - "AddTabUseCase"
Cohesion: 0.22
Nodes (8): AllTabsViewModel, AddTabUseCase, AllTabsStateContext, AllTabsStateContextProxy, AllTabsViewModelImpl, .context, Context, AllTabsViewModel

### Community 128 - "AlamofireHTTPRxAdaptee"
Cohesion: 0.24
Nodes (9): AlamofireHTTPRxAdaptee, Endpoint, Future, ObserverWrapper, Response, Result, Server, URLRequest (+1 more)

### Community 129 - "JSPluginsBuilder"
Cohesion: 0.24
Nodes (7): JSPluginsBuilder, .jsProgram, Self, HandlablePlugin, WKScriptMessageHandler, JSPluginsProgramImpl, Program

### Community 130 - "ig.js"
Cohesion: 0.36
Nodes (12): cottonFindTitleFromNode(), cottonHandleHtml(), cottonHandleHttpResponseText(), cottonIsIgEnabled(), cottonLog(), cottonNativeAppSendSingleNode(), cottonSearchAdditionalData(), cottonSearchSharedData() (+4 more)

### Community 131 - "package.json"
Cohesion: 0.15
Nodes (12): author, description, devDependencies, eslint, license, main, name, private (+4 more)

### Community 132 - "ClosureWrapper"
Cohesion: 0.31
Nodes (9): ClosureWrapper, CombinePromiseWrapper, Endpoint, Future, Hasher, Response, Result, Server (+1 more)

### Community 133 - "MockedHTTPAdapteeWithFail"
Cohesion: 0.24
Nodes (9): MockedHTTPAdapteeWithFail, Endpoint, Future, ObserverWrapper, Response, Result, Server, URLRequest (+1 more)

### Community 134 - "WebViewController"
Cohesion: 0.17
Nodes (9): Host, Site, URL, WebViewController, .canGoBack, .canGoForward, .host, .siteSettings (+1 more)

### Community 135 - "WebViewControllerProxy"
Cohesion: 0.18
Nodes (9): Host, Site, URL, WebViewControllerProxy, .canGoBack, .canGoForward, .host, .siteSettings (+1 more)

### Community 136 - "LinkTagsViewController"
Cohesion: 0.21
Nodes (6): LinkTagsDelegate, LinkTagsViewController, IndexPath, UICollectionView, UICollectionViewCell, UICollectionViewController

### Community 137 - "SearchSuggestionsListDelegate"
Cohesion: 0.22
Nodes (10): SearchSuggestionsView, .body, S, String, SearchSuggestionsViewV2, .body, S, SearchSuggestionsState (+2 more)

### Community 138 - "StateHolder"
Cohesion: 0.23
Nodes (6): Any, T, UseCaseLocator, StateHolder, String, T

### Community 139 - "GenericConcurrentDataService"
Cohesion: 0.32
Nodes (8): DispatchQueueInterface, GenericConcurrentDataService, Command, Result, ServiceData, ServiceError, NSRecursiveLock, Promise

### Community 140 - "SearchSuggestionsVMTestFixture"
Cohesion: 0.29
Nodes (5): EndpointHttpError, FakeKnownDomainsSource, SearchSuggestionsViewModelImplTests, SearchSuggestionsVMTestFixture, String

### Community 141 - "FakeWebViewStateContext"
Cohesion: 0.18
Nodes (7): FakeWebViewStateContext, .isDohEnabled, .pluginsSource, .webViewConfiguration, String, URL, WKWebViewConfiguration

### Community 142 - "SearchFieldView"
Cohesion: 0.19
Nodes (9): LocalizedStringKey, SearchFieldView, .body, SearchFieldView_Previews, .previews, Binding, String, SearchFieldViewModel (+1 more)

### Community 143 - "Theme"
Cohesion: 0.18
Nodes (11): LightTheme, .searchBarButtonBackgroundColor, UIColor, UIColor, UIStatusBarStyle, Theme, .searchBarSeparatorColor, .statusBarStyle (+3 more)

### Community 144 - "NetworkReachabilityStatus"
Cohesion: 0.17
Nodes (12): Alamofire.NetworkReachabilityManager.NetworkReachabilityStatus, Alamofire.NetworkReachabilityManager.NetworkReachabilityStatus.ConnectionType, .httpKitValue, .httpKitValue, ConnectionType, cellular, ethernetOrWiFi, NetworkReachabilityStatus (+4 more)

### Community 145 - ".resolvedDomainName"
Cohesion: 0.21
Nodes (8): AnyPublisher, GDNSJsonClientRxSubscriber, GDNSJsonClientSubscriber, ResolvedURLProducer, String, URL, GDNSjsonProducer, GDNSjsonPublisher

### Community 146 - "AlamofireHTTPRxVoidAdaptee"
Cohesion: 0.24
Nodes (8): AlamofireHTTPRxVoidAdaptee, Endpoint, Future, ObserverWrapper, Result, Server, URLRequest, Void

### Community 147 - "HTMLVideoTag"
Cohesion: 0.26
Nodes (9): CodingKeys, poster, src, HTMLVideoTag, Decoder, String, URL, VideoFileNameble (+1 more)

### Community 148 - "WebViewNavigatable"
Cohesion: 0.21
Nodes (4): Context, UIViewControllerType, ToolbarLegacyView, WebViewNavigatable

### Community 149 - ".collectionView"
Cohesion: 0.17
Nodes (9): Sizes, CGFloat, CGSize, IndexPath, UICollectionView, UICollectionViewCell, UICollectionViewLayout, CGFloat (+1 more)

### Community 150 - "DisableableButton"
Cohesion: 0.20
Nodes (10): Binding, BrowserToolbarViewModel, ToolbarViewV2, .body, DisableableButton, .body, MainActor, String (+2 more)

### Community 151 - "SearchServiceData"
Cohesion: 0.18
Nodes (10): SearchServiceData, .resolvedURL, .searchURL, .suggestions, SuggestionsRequest, String, URL, DomainResolvingData (+2 more)

### Community 152 - "SearchBarDelegateImpl"
Cohesion: 0.26
Nodes (6): SearchBarDelegateImpl, NSRange, SearchBarViewModel, String, UISearchBar, UISearchBarDelegate

### Community 153 - "BrowserToolbarState"
Cohesion: 0.18
Nodes (6): BrowserToolbarError, navigationUpdateWithoutData, progressUpdateWithoutData, BrowserToolbarState, BrowserToolbarStateTransitioning, Double

### Community 154 - "CommandExecutionData"
Cohesion: 0.17
Nodes (11): CommandExecutionData, finished, inProgress, notStarted, started, E, Input, Output (+3 more)

### Community 155 - "MockReplaceSelectedTabUseCase"
Cohesion: 0.24
Nodes (6): MockReplaceSelectedTabUseCase, async, Void, Site, String, TopSitesViewModelImplTests

### Community 156 - ".present"
Cohesion: 0.31
Nodes (6): ActionHandler, AlertPresenter, String, UIViewController, UIAlertAction, UIAlertController

### Community 157 - "FakeSearchViewContext"
Cohesion: 0.22
Nodes (8): Actor, DomainsHistory, KnownDomainsSource, GenericDataServiceActorProtocol, FakeSearchViewContext, .appAsyncApiTypeValue, .webAutocompletionSourceValue, Mockable

### Community 158 - "Downloadable"
Cohesion: 0.27
Nodes (8): download(), Downloadable, .excludeFromBackup, .fileName, String, URL, DownloadRequest, FileDownloadProducer

### Community 159 - "FileDownloadViewModel"
Cohesion: 0.20
Nodes (10): fetchRemoteResourceInfo(), URL, FileDownloadDelegate, FileDownloadViewModel, .downloadState, Never, Signal, String (+2 more)

### Community 160 - "GoogleDNSEndpointError"
Cohesion: 0.18
Nodes (9): GoogleDNSEndpointError, dnsStatusError, emptyAnswers, .errorDescription, recordTypeParsing, Int32, String, UInt32 (+1 more)

### Community 161 - "CottonPluginError"
Cohesion: 0.18
Nodes (10): CottonPluginError, emptyHtml, jsEvaluationIsNotString, jsEvaluationIsNotURL, nilJSEvaluationResult, notExpectedKey, noVideoTags, parseError (+2 more)

### Community 162 - "MessageKey"
Cohesion: 0.18
Nodes (10): MessageKey, DOMVideoTags, html, log, WKScriptMessage, MessageKey, log, singleVideoNode (+2 more)

### Community 163 - "BaseViewController"
Cohesion: 0.22
Nodes (8): LoadingProgressViewController, UIProgressView, BaseViewController, UIIdiomable, .isPad, UIView, UIViewController, UIViewController

### Community 164 - "ThemeProvider"
Cohesion: 0.20
Nodes (5): UISearchBar, UIToolbar, UIView, ThemeProvider, .themeType

### Community 165 - "ObservableObject"
Cohesion: 0.25
Nodes (8): ObservableObject, String, Void, TappableTextOverlayView, .body, TappableTextOverlayView_Previews, .previews, TappableTextOverlayViewModel

### Community 166 - "ClearCancelButtonViewModel"
Cohesion: 0.25
Nodes (8): ClearCancelButtonViewModel, ClearCancelPairButton, .body, ClearCancelPairButton_Previews, .previews, LocalizedStringKey, Void, .body

### Community 167 - "GoogleDNSOverJSONResponse"
Cohesion: 0.22
Nodes (10): CodingKeys, answer, ipAddress, name, status, type, GoogleDNSOverJSONResponse, .successCodes (+2 more)

### Community 168 - "CottonRestKit/Extensions/HttpKotlinTypes+Extensions.swift"
Cohesion: 0.20
Nodes (8): Array, .kotlinArray, HTTPRequestInfo, .urlRequest, KotlinArray, .empty, URLRequest, URLQueryPair

### Community 169 - "DownloadState"
Cohesion: 0.20
Nodes (9): DownloadState, error, finished, `in`, initial, started, CGFloat, Error (+1 more)

### Community 170 - ".insert"
Cohesion: 0.22
Nodes (5): CottonBase.Host, InMemoryDomainSearchProvider, InMemoryDomainSearchProvider.StateHolder, StateHolder, String

### Community 171 - "Site"
Cohesion: 0.27
Nodes (6): Site, .id, Settings, String, URL, URLDomainNameResolve

### Community 172 - "SearchServiceError"
Cohesion: 0.20
Nodes (9): SearchServiceError, .errorDescription, failedToCreateSearchEngine, requestDataWhenNotCorrectState, strategyError, xmlParsingError, zombyInstance, NSError (+1 more)

### Community 173 - "TabsPreviewState"
Cohesion: 0.20
Nodes (6): BaseState, TabsPreviewState, .itemsNumber, loading, tabs, TabsPreviewStateTransitioning

### Community 174 - "TabStateContextProxy"
Cohesion: 0.24
Nodes (4): String, TabStateContext, TabStateContextProxy, .tabTitle

### Community 175 - "BrowserToolbarAction"
Cohesion: 0.20
Nodes (9): BrowserToolbarAction, goBack, goForward, reload, replaceWebInterface, stopWebViewReusage, updateNavigation, updateProgress (+1 more)

### Community 176 - "WebViewVMFixture"
Cohesion: 0.24
Nodes (7): DomainName, Site, String, WebViewVMFixture, MockResolveDNSUseCase, async, URL

### Community 177 - ".evaluateJavaScriptV2"
Cohesion: 0.29
Nodes (7): MockedWebViewWithError, Any, Error, MainActor, Sendable, String, Void

### Community 178 - "GDNSRequestParams"
Cohesion: 0.28
Nodes (7): Endpoint, GDNSRequestParams, .urlQueryItems, DomainName, String, URLQueryItem, GDNSjsonEndpoint

### Community 179 - ".makeRequest"
Cohesion: 0.56
Nodes (5): B, Endpoint, Server, String, T

### Community 180 - "AppDelegate"
Cohesion: 0.25
Nodes (6): AppDelegate, Any, UIApplication, AppAssembler, UIApplicationDelegate, UIResponder

### Community 181 - "UIViewController"
Cohesion: 0.36
Nodes (4): Self, String, T, UIViewController

### Community 182 - "Box"
Cohesion: 0.25
Nodes (7): WKNavigationType, .debugDescription, CustomDebugStringConvertible, Box, .debugDescription, String, T

### Community 183 - "BrowserToolbarViewContextImpl"
Cohesion: 0.25
Nodes (6): BrowserToolbarViewContextImpl, .siteNavigationDelegate, .vcFactory, BrowserToolbarViewModel, BrowserToolbarViewModel, BrowserToolbarViewContext

### Community 184 - "HTMLVideoTag"
Cohesion: 0.25
Nodes (8): HTMLVideoTag, .hostname, .url, InstagramVideoNode, .hostname, .url, String, URL

### Community 185 - "CottonMenuItem"
Cohesion: 0.22
Nodes (8): CottonMenuItem, asyncApi, defaultTabContent, observingApi, tabAddPosition, uiFramework, webAutocompletionSource, String

### Community 186 - "SuggestionRowView"
Cohesion: 0.28
Nodes (8): .dynamicView, Mode, domain, suggestion, SuggestionRowView, .body, Binding, String

### Community 187 - ".init"
Cohesion: 0.22
Nodes (5): AnyCancellable, ViewModelConsumer, CGRect, NSCoder, ViewModelType

### Community 188 - "AppError"
Cohesion: 0.22
Nodes (9): AppError, commandNotFinishedYet, erasedSearchDataServiceError, .errorDescription, searchDataServiceError, tabsServiceError, zombieSelf, Error (+1 more)

### Community 189 - "SearchBarStateContext"
Cohesion: 0.25
Nodes (4): SearchBarStateContext, SearchBarStateContextProxy, String, URL

### Community 190 - "SearchSuggestionsStateContext"
Cohesion: 0.31
Nodes (5): SearchSuggestionsStateContext, SearchSuggestionsStateContextProxy, KnownDomains, QuerySuggestions, String

### Community 191 - "TabAction"
Cohesion: 0.22
Nodes (8): String, TabAction, activate, .allCases, applyReplace, applySelection, close, load

### Community 192 - "StateHolder"
Cohesion: 0.36
Nodes (3): StateHolder, String, UserDefaults

### Community 193 - "DataServiceLocator"
Cohesion: 0.28
Nodes (4): DataServiceLocator, Any, String, T

### Community 194 - "BaseViewModel"
Cohesion: 0.28
Nodes (6): BaseViewModel, .context, .statePublisher, Context, S, Published

### Community 195 - ".transferToRxState"
Cohesion: 0.32
Nodes (6): HTTPRxAdapter, Endpoint, Response, Server, Signal, Void

### Community 196 - "TabViewContextImpl"
Cohesion: 0.29
Nodes (6): Site, URL, TabViewContextImpl, .isDohEnabled, .observingApiTypeValue, .tabsSubject

### Community 197 - "MainScreenSubview"
Cohesion: 0.25
Nodes (8): MainScreenSubview, dummyView, filesGrid, linkTags, loadingProgress, searchBar, toolbar, webContentContainer

### Community 199 - "LinksBadgeView"
Cohesion: 0.25
Nodes (6): String, LinksBadgeView, .tagTypeLabel, UILabel, UICollectionViewCell, UICollectionViewLayoutAttributes

### Community 200 - "PhoneSearchBarLegacyView"
Cohesion: 0.39
Nodes (5): PhoneSearchBarLegacyView, Context, SearchBarViewModel, UISearchBarDelegate, UIViewControllerType

### Community 201 - "TabletSearchBarLegacyView"
Cohesion: 0.36
Nodes (5): Context, SearchBarViewModel, UISearchBarDelegate, UIViewControllerType, TabletSearchBarLegacyView

### Community 202 - "SearchSuggestionsLegacyView"
Cohesion: 0.36
Nodes (5): SearchSuggestionsLegacyView, Context, S, String, UIViewControllerType

### Community 203 - "TabletTabsLegacyView"
Cohesion: 0.32
Nodes (5): AllTabsViewModel, Context, UIViewControllerType, TabletTabsLegacyView, .body

### Community 204 - ".makeTask"
Cohesion: 0.29
Nodes (6): Error, Input, Output, Task, Void, TaskPriority

### Community 205 - "StateContext"
Cohesion: 0.32
Nodes (5): BrowserToolbarStateContext, BrowserToolbarStateContextProxy, .siteExternalDelegate, .siteNavigationDelegate, StateContext

### Community 206 - ".evaluateJavaScriptV2"
Cohesion: 0.39
Nodes (6): Any, Error, MainActor, String, Void, WebViewActionAllCasesJSSubject

### Community 208 - "MenuButton"
Cohesion: 0.29
Nodes (6): MenuButton, .body, MenuButton_Previews, .previews, Binding, .body

### Community 209 - "PackageDescription"
Cohesion: 0.29
Nodes (4): String, String, PackageDescription, String

### Community 210 - "AlamofireReachabilityAdaptee"
Cohesion: 0.33
Nodes (4): AlamofireReachabilityAdaptee, Listener, Server, NetworkReachabilityManager

### Community 211 - "DispatchQueue"
Cohesion: 0.29
Nodes (4): Listener, Dispatch, DispatchQueue, convention

### Community 212 - "MainScreenRoute"
Cohesion: 0.38
Nodes (5): MainScreenRoute, menu, openTab, CGRect, UIView

### Community 213 - "ContentCoordinatorsInterface"
Cohesion: 0.33
Nodes (5): ContentCoordinatorsInterface, BrowserContentCoordinatorsKey, EnvironmentValues, .browserContentCoordinators, EnvironmentKey

### Community 214 - "TrieNode"
Cohesion: 0.38
Nodes (4): T, TrieNode, .debugDescription, .isLeaf

### Community 216 - "URL"
Cohesion: 0.29
Nodes (6): URL, .hasIPHost, .hasIPv4Host, .hasIPv6Host, .isAppleMapsURL, .isStoreURL

### Community 217 - "SearchBarInViewMode"
Cohesion: 0.29
Nodes (5): SearchBarInViewMode, .modeHandler, .showCancelButton, C, String

### Community 218 - "Error"
Cohesion: 0.29
Nodes (6): Error, .errorDescription, notImplemented, unexpectedStateForAction, String, WebViewModelState

### Community 219 - "TopSitesStateTransitioningTests"
Cohesion: 0.33
Nodes (3): Site, String, TopSitesStateTransitioningTests

### Community 220 - "UIConstants.swift"
Cohesion: 0.33
Nodes (4): UIColor, CGFloat, .tabWidth, UIConstants

### Community 221 - ".aaGetIPaddress"
Cohesion: 0.33
Nodes (3): String, URL, URL

### Community 222 - ".evaluateWithRecovery"
Cohesion: 0.33
Nodes (4): DefaultTrustEvaluator, SecTrust, Self, String

### Community 223 - ".script"
Cohesion: 0.40
Nodes (4): JSPluginFactory, String, WKUserScript, WKUserScriptInjectionTime

### Community 224 - "CSSBackgroundImage"
Cohesion: 0.33
Nodes (4): CSSBackgroundImage, .firstURL, URL, CssParser

### Community 225 - "URL"
Cohesion: 0.33
Nodes (5): ResolvedURLProducer, String, URL, .rxHttpHost, HostProducer

### Community 226 - ".failure"
Cohesion: 0.53
Nodes (4): Combine.Future, Future, Output, Failure

### Community 227 - "Parser"
Cohesion: 0.33
Nodes (3): Parser, .current, .next

### Community 229 - "DownloadButtonState"
Cohesion: 0.33
Nodes (6): DownloadButtonState, canDownload, downloaded, downloading, .title, String

### Community 230 - "ReloadWithCompletion.swift"
Cohesion: 0.47
Nodes (4): ReloadableCollection, Void, UICollectionView, UITableView

### Community 231 - "ViewModelInterface"
Cohesion: 0.53
Nodes (3): CompletionCallback, Action, ViewModelInterface

### Community 232 - ".read"
Cohesion: 0.33
Nodes (3): String, Bundle, XmlSearchPluginResource

### Community 234 - "MockFetchAutocompleteSuggestionsUseCase"
Cohesion: 0.47
Nodes (4): MockFetchAutocompleteSuggestionsUseCase, async, Input, Output

### Community 235 - "ProgressResponse"
Cohesion: 0.40
Nodes (5): ProgressResponse, complete, progress, T, Progress

### Community 236 - "InstagramVideoArray"
Cohesion: 0.40
Nodes (3): InstagramVideoArray, Decoder, InstagramVideoNode

### Community 237 - ".init"
Cohesion: 0.40
Nodes (4): Encoder, Server, TimeInterval, Reachability

### Community 238 - ".tableView"
Cohesion: 0.40
Nodes (3): IndexPath, UITableView, UITableViewCell

### Community 239 - ".findDataService"
Cohesion: 0.40
Nodes (4): ServiceRegistry.StateHolder, .tabsService, String, T

### Community 240 - ".subscript"
Cohesion: 0.40
Nodes (3): Collection, Index, Iterator

### Community 241 - "LeadingTrimmed"
Cohesion: 0.50
Nodes (3): LeadingTrimmed, .wrappedValue, String

### Community 242 - "ImmediateDispatchQueue"
Cohesion: 0.40
Nodes (3): ImmediateDispatchQueue, convention, Sendable

### Community 243 - "MockCreateSearchURLUseCase"
Cohesion: 0.60
Nodes (4): MockCreateSearchURLUseCase, async, Input, Output

### Community 245 - "README.md"
Cohesion: 0.50
Nodes (3): Initial setup was, Intallation, JavaScript info

### Community 251 - "HashType"
Cohesion: 0.67
Nodes (3): HashType, id, unrestricted

### Community 252 - "NumberType"
Cohesion: 0.67
Nodes (3): NumberType, integer, number

### Community 254 - "Site.Settings"
Cohesion: 1.00
Nodes (3): Site.Settings, .webViewConfig, WKWebViewConfiguration

## Knowledge Gaps
- **731 isolated node(s):** `String`, `AutoMockable`, `AutoHashable`, `.unitTesting`, `.httpKitValue` (+726 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 1571 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **15 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Bool` connect `Bool` to `WebViewController`, `TabsDBClient`, `TabViewModelImpl`, `TabsDataService`, `AnyViewController`, `DnsError`, `BrowserToolbarController`, `LinkTagsCoordinator`, `Int`, `WebViewModelImpl`, `FeatureManager`, `Tab`, `SearchSuggestionsViewController`, `AnyObject`, `BrowserToolbarView`, `TabView`, `CoordinatorOwner`, `TopSitesViewModel`, `SearchBarState`, `WebViewModelState`, `Scanner`, `FilesGridCoordinator`, `SearchBarCoordinator`, `AddedTabPosition`, `WebViewAction`, `Equatable`, `FilesGridViewController`, `TabletView`, `Database`, `URLInfo`, `UIFrameworkType`, `UIImageView`, `WebContentCoordinator`, `TabsPreviewsViewController`, `ApplicationFeature`, `Coordinator`, `ImageSource`, `WebViewStateContextProxy`, `BrowserToolbarViewModelImpl`, `BrowserMenuView`, `SwiftUIMode`, `LoadingProgressCoordinator`, `TabPreviewCell`, `TabsListError`, `SearchBarAction`, `FakeTabStateContext`, `ViewModelStateMachineTests.swift`, `SearchBarLegacyView`, `JavaScriptEvaluateble`, `.showNext`, `TabletSearchBarViewController`, `.source`, `JSPluginsSource`, `ObservingApiType`, `SearchBarError`, `SwiftUIPreviewable`, `Character`, `MenuStatefullLabel`, `CounterView`, `Trie`, `SearchBarViewV2`, `JSPluginsBuilder`, `WebViewController`, `WebViewControllerProxy`, `LinkTagsViewController`, `FakeWebViewStateContext`, `SearchFieldView`, `NetworkReachabilityStatus`, `DisableableButton`, `SearchBarDelegateImpl`, `BrowserToolbarState`, `Downloadable`, `BaseViewController`, `ClearCancelButtonViewModel`, `Site`, `SearchServiceError`, `TabStateContextProxy`, `BrowserToolbarAction`, `GDNSRequestParams`, `AppDelegate`, `SearchBarStateContext`, `TabAction`, `StateHolder`, `TabViewContextImpl`, `MenuButton`, `AlamofireReachabilityAdaptee`, `DispatchQueue`, `TrieNode`, `String`, `URL`, `SearchBarInViewMode`, `.script`, `MockedJSPluginsProgram`, `.isSimilar`?**
  _High betweenness centrality (0.183) - this node is a cross-community bridge._
- **Why does `CoreBrowser` connect `CoreBrowser` to `CottonViewModels`, `TabsDBClient`, `RestClient`, `Foundation`, `AutoMockable`, `TabViewModelImpl`, `WebAutoCompletionSource`, `TabsDataService`, `Int`, `ViewModelKit`, `ReplaceSelectedTabUseCase`, `TabsViewController`, `BaseListViewModel`, `FeatureManager`, `MockReplaceSelectedTabUseCase`, `Tab`, `BrowserToolbarView`, `TopSitesViewModel`, `TabsPreviewsError`, `TabsPreviewState`, `AppCoordinator`, `AddedTabPosition`, `TabletView`, `Testing`, `UIFrameworkType`, `TabsPreviewsViewController`, `ApplicationFeature`, `SearchBarBaseViewController`, `TopSitesViewV2`, `FeatureManager.StateHolder`, `MainScreenRoute`, `SwiftUIMode`, `TabPreviewCell`, `SearchBarAction`, `.handleTabSelection`, `.showNext`, `.start`, `MockFetchAutocompleteSuggestionsUseCase`, `ObservingApiType`, `ViewModelState`, `GenericEnumFeature`, `Database.swift`, `State`, `ViewModelAction`, `AddTabUseCase`?**
  _High betweenness centrality (0.132) - this node is a cross-community bridge._
- **Why does `Int` connect `Int` to `AlamofireHTTPRxAdaptee`, `MockedHTTPAdapteeWithFail`, `AutoMockable`, `LinkTagsViewController`, `WebAutoCompletionSource`, `TabsDataService`, `AnyViewController`, `TabViewModelImpl`, `AlamofireHTTPRxVoidAdaptee`, `HTMLVideoTag`, `Token`, `.collectionView`, `DisableableButton`, `TabsViewController`, `Bool`, `Tab`, `SearchSuggestionsViewController`, `FileDownloadViewModel`, `BrowserToolbarView`, `GoogleDNSOverJSONResponse`, `TabsPreviewsError`, `TabsPreviewState`, `HttpError`, `AddedTabPosition`, `FilesGridViewController`, `TabletView`, `UIFrameworkType`, `StateHolder`, `TabsPreviewsViewController`, `SearchBarBaseViewController`, `TopSitesViewController`, `LinksBadgeView`, `SearchSuggestionsViewState`, `TabPreviewCell`, `UIConstants.swift`, `ViewModelStateMachineTests.swift`, `DDGoSuggestionsResponse`, `GSearchSuggestionsResponse`, `.handleTabSelection`, `.showNext`, `DownloadButtonCellView`, `.source`, `AlamofireHTTPAdaptee`, `.tableView`, `ObservingApiType`, `CounterView`, `Trie`, `ViewModelAction`?**
  _High betweenness centrality (0.125) - this node is a cross-community bridge._
- **What connects `String`, `AutoMockable`, `AutoHashable` to the rest of the system?**
  _731 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `CottonViewModels` be split into smaller, more focused modules?**
  _Cohesion score 0.05493827160493827 - nodes in this community are weakly interconnected._
- **Should `WebViewController` be split into smaller, more focused modules?**
  _Cohesion score 0.05029838022165388 - nodes in this community are weakly interconnected._
- **Should `TabsDBClient` be split into smaller, more focused modules?**
  _Cohesion score 0.050921861281826165 - nodes in this community are weakly interconnected._