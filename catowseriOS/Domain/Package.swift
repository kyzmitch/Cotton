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
        )
    ],
    dependencies: [
        .package(path: "../Base")
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
                .product(name: .cottonNetworkingLibrary, package: .basePackage),
                .product(name: .reactiveSwiftFramework, package: .reactiveSwiftFramework),
                .product(name: .alamofireFramework, package: .alamofireFramework),
                .product(name: .cottonRestKit, package: .basePackage)
            ]
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
