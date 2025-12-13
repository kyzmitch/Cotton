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
    
    // MARK: - Frameworks/Kits
    
    static let genericServiceKit = "GenericServiceKit"
    static let baseUseCaseKit = "BaseUseCaseKit"
    
    // MARK: - Frameworks/Kits from Base package

    static let cottonNetworkingLibrary = "CottonNetworking"
    static let cottonRestKit = "CottonRestKit"
    
    // MARK: - 3rd party

    static let reactiveSwiftFramework = "ReactiveSwift"
    static let alamofireFramework = "Alamofire"
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
            name: .baseUseCaseKit,
            targets: [.baseUseCaseKit]
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
            name: .baseUseCaseKit,
            dependencies: []
        ),
        .target(
            name: .searchLibrary,
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
