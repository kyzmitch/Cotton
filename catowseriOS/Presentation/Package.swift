// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// MARK: - Identifiers

private extension String {
    
    // MARK: - Root
    
    static let presentationPackage = "Presentation"
    static let domainPackage = "Domain"
    
    // MARK: - Libraries
    
    static let searchViewsLibrary = "SearchViews"
    static let searchSuggestionsLibrary = "SearchSuggestions"
    static let commonDelegatesLibrary = "CommonDelegatesLibrary"
    
    // MARK: - Frameworks/Kits
    
    static let viewsBaseLibrary = "ViewsBase"
    static let cottonDesignKit = "CottonDesignKit"

    // MARK: - Domain libraries
    
    static let searchLibrary = "CottonSearch"
    static let tabsLibrary = "CottonTabs"
    static let cottonDependencyAssembly = "CottonDependencyAssembly"
    static let coreBrowserLibrary = "CoreBrowser"
    static let viewModelsLibrary = "CottonViewModels"
    static let featureFlagsLibrary = "FeatureFlags"
    
    // MARK: - Domain Frameworks/Kits
    
    static let featureFlagsKit = "FeatureFlagsKit"
    
    // MARK: - Base Frameworks/Kits
    
    // MARK: - 3rd party
}

// MARK: - Package

let package = Package(
    name: .presentationPackage,
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: .presentationPackage,
            targets: [.presentationPackage]
        ),
        .library(
            name: .searchViewsLibrary,
            targets: [.searchViewsLibrary]
        ),
        .library(
            name: .searchSuggestionsLibrary,
            targets: [.searchSuggestionsLibrary]
        ),
        .library(
            name: .viewsBaseLibrary,
            targets: [.viewsBaseLibrary]
        ),
        .library(
            name: .cottonDesignKit,
            targets: [.cottonDesignKit]
        ),
        .library(
            name: .commonDelegatesLibrary,
            targets: [.commonDelegatesLibrary]
        )
    ],
    dependencies: [
        .package(path: "../Domain")
    ],
    targets: [
        .target(
            name: .presentationPackage,
            dependencies: [
            ]
        ),
        .target(
            name: .searchViewsLibrary,
            dependencies: [
                .target(name: .viewsBaseLibrary),
                .target(name: .cottonDesignKit),
                .target(name: .commonDelegatesLibrary),
                .product(name: .coreBrowserLibrary, package: .domainPackage),
                .product(name: .tabsLibrary, package: .domainPackage),
                .product(name: .featureFlagsKit, package: .domainPackage),
                .product(name: .featureFlagsLibrary, package: .domainPackage),
                .product(name: .viewModelsLibrary, package: .domainPackage)
            ]
        ),
        .target(
            name: .searchSuggestionsLibrary,
            dependencies: [
                .product(name: .viewModelsLibrary, package: .domainPackage)
            ]
        ),
        .target(
            name: .viewsBaseLibrary,
            dependencies: [
                .product(name: .coreBrowserLibrary, package: .domainPackage),
                .product(name: .featureFlagsKit, package: .domainPackage),
                .product(name: .viewModelsLibrary, package: .domainPackage)
            ]
        ),
        .target(
            name: .cottonDesignKit,
            dependencies: [
                .target(name: .viewsBaseLibrary)
            ]
        ),
        .target(
            name: .commonDelegatesLibrary,
            dependencies: [
                .product(name: .viewModelsLibrary, package: .domainPackage)
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
