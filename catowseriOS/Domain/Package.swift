// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// MARK: - Identifiers

private extension String {
    
    // MARK: - Root
    
    static let domainPackage = "Domain"
    static let basePackage = "Base"
    
    // MARK: - Libraries
    
    static let searchLibrary = "CottonSearch"
    static let tabsLibrary = "CottonTabs"
    static let cottonDependencyAssembly = "CottonDependencyAssembly"
    static let coreBrowserLibrary = "CoreBrowser"
    static let useCasesLibrary = "CottonUseCases"
    
    // MARK: - Frameworks/Kits
    
    static let genericServiceKit = "GenericServiceKit"
    static let viewModelKit = "ViewModelKit"
    static let baseUseCaseKit = "BaseUseCaseKit"
    static let featureFlagsKit = "FeatureFlagsKit"
    
    // MARK: - Frameworks/Kits from Base package

    static let cottonNetworkingLibrary = "CottonNetworking"
    static let cottonRestKit = "CottonRestKit"
    static let cottonBase = "CottonBase"
    static let autoMockableKit = "AutoMockable"
    
    // MARK: - 3rd party

    static let reactiveSwiftFramework = "ReactiveSwift"
    static let alamofireFramework = "Alamofire"
    static let swXmlHashFramework = "SWXMLHash"
}

// MARK: - Package

let package = Package(
    name: .domainPackage,
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: .domainPackage,
            targets: [.domainPackage]
        ),
        .library(
            name: .genericServiceKit,
            targets: [.genericServiceKit]
        ),
        .library(
            name: .viewModelKit,
            targets: [.viewModelKit]
        ),
        .library(
            name: .useCasesLibrary,
            targets: [.useCasesLibrary]
        ),
        .library(
            name: .baseUseCaseKit,
            targets: [.baseUseCaseKit]
        ),
        .library(
            name: .featureFlagsKit,
            targets: [.featureFlagsKit]
        ),
        .library(
            name: .searchLibrary,
            targets: [.searchLibrary]
        ),
        .library(
            name: .tabsLibrary,
            targets: [.tabsLibrary]
        ),
        .library(
            name: .cottonDependencyAssembly,
            targets: [.cottonDependencyAssembly]
        ),
        .library(
            name: .coreBrowserLibrary,
            targets: [.coreBrowserLibrary]
        )
    ],
    dependencies: [
        .package(path: "../Base"),
        .package(
            url: "https://github.com/ReactiveCocoa/ReactiveSwift",
            exact: "7.0.0"
        ),
        .package(
            url: "https://github.com/Alamofire/Alamofire.git",
            exact: "5.9.1"
        ),
        .package(
            url: "https://github.com/drmohundro/SWXMLHash",
            exact: "7.0.1"
        )
    ],
    targets: [
        .target(
            name: .domainPackage,
            dependencies: [
                .target(name: .genericServiceKit)
            ]
        ),
        .target(
            name: .genericServiceKit,
            dependencies: []
        ),
        .target(
            name: .viewModelKit,
            dependencies: []
        ),
        .target(
            name: .baseUseCaseKit,
            dependencies: []
        ),
        .target(
            name: .featureFlagsKit,
            dependencies: [
                .target(name: .coreBrowserLibrary),
                .target(name: .genericServiceKit),
                .product(name: .reactiveSwiftFramework, package: .reactiveSwiftFramework)
            ]
        ),
        .target(
            name: .searchLibrary,
            dependencies: [
                .target(name: .genericServiceKit),
                .target(name: .cottonDependencyAssembly),
                .target(name: .coreBrowserLibrary),
                .product(name: .cottonNetworkingLibrary, package: .basePackage),
                .product(name: .reactiveSwiftFramework, package: .reactiveSwiftFramework),
                .product(name: .alamofireFramework, package: .alamofireFramework),
                .product(name: .cottonRestKit, package: .basePackage)
            ]
        ),
        .target(
            name: .tabsLibrary,
            dependencies: [
                .target(name: .genericServiceKit),
                .target(name: .cottonDependencyAssembly),
                .product(name: .cottonNetworkingLibrary, package: .basePackage),
                .product(name: .reactiveSwiftFramework, package: .reactiveSwiftFramework),
                .product(name: .alamofireFramework, package: .alamofireFramework),
                .product(name: .cottonRestKit, package: .basePackage)
            ]
        ),
        .target(
            name: .cottonDependencyAssembly,
            dependencies: []
        ),
        .target(
            name: .coreBrowserLibrary,
            dependencies: [
                .product(name: .cottonBase, package: .basePackage),
                .product(name: .autoMockableKit, package: .basePackage),
                .product(name: .reactiveSwiftFramework, package: .reactiveSwiftFramework),
                .product(name: .swXmlHashFramework, package: .swXmlHashFramework)
            ],
            resources: [
                .process("Resources/topdomains.txt")
            ]
        ),
        .target(
            name: .useCasesLibrary,
            dependencies: [
                .target(name: .coreBrowserLibrary),
                .target(name: .searchLibrary),
                .target(name: .tabsLibrary),
                .target(name: .genericServiceKit),
                .product(name: .autoMockableKit, package: .basePackage),
                .product(name: .reactiveSwiftFramework, package: .reactiveSwiftFramework)
            ]
        ),
        .binaryTarget(
            name: .cottonBase,
            path: "../../cotton-base/build/XCFrameworks/release/CottonBase.xcframework"
        ),
        .testTarget(
            name: "DomainTests",
            dependencies: [
                .target(name: .domainPackage)
            ]
        ),
        .testTarget(
            name: "GenericServiceKitTests",
            dependencies: [
                .target(name: .genericServiceKit)
            ]
        ),
        .testTarget(
            name: "BaseUseCaseKitTests",
            dependencies: [
                .target(name: .genericServiceKit)
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
