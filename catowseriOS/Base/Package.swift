// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// MARK: - Identifiers

private extension String {
    
    // MARK: - Root

    static let basePackage = "Base"
    static let cottonBase = "CottonBase"
    
    // MARK: - 3rd party

    static let reactiveSwiftFramework = "ReactiveSwift"
    static let swXmlHashFramework = "SWXMLHash"
    static let alamofireFramework = "Alamofire"
    
    // MARK: - Libraries
    
    // MARK: - Frameworks/Kits
    
    static let cottonRestKit = "CottonRestKit"
    static let autoMockableKit = "AutoMockable"
    static let cottonReactiveRestKit = "CottonReactiveRestKit"
    static let cottonNetworkingLibrary = "CottonNetworking"
}

let package = Package(
    name: .basePackage,
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: .basePackage,
            targets: [
                .basePackage
            ]
        ),
        .library(
            name: .cottonRestKit,
            targets: [
                .cottonRestKit
            ]
        ),
        .library(
            name: .cottonReactiveRestKit,
            targets: [
                .cottonReactiveRestKit
            ]
        ),
        .library(
            name: .autoMockableKit,
            targets: [
                .autoMockableKit
            ]
        ),
        .library(
            name: .cottonBase,
            targets: [
                .cottonBase
            ]
        ),
        .library(
            name: .cottonNetworkingLibrary,
            targets: [
                .cottonNetworkingLibrary
            ]
        ),
    ],
    dependencies: [
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
            name: .basePackage
        ),
        .target(
            name: .autoMockableKit
        ),
        .target(
            name: .cottonRestKit,
            dependencies: [
                .target(name: .cottonBase),
                .target(name: .autoMockableKit)
            ]
        ),
        .target(
            name: .cottonReactiveRestKit,
            dependencies: [
                .target(name: .cottonRestKit),
                .target(name: .cottonBase),
                .target(name: .autoMockableKit),
                .product(name: .reactiveSwiftFramework, package: .reactiveSwiftFramework)
            ]
        ),
        .target(
            name: .cottonNetworkingLibrary,
            dependencies: [
                .target(name: .cottonRestKit),
                .target(name: .cottonReactiveRestKit),
                .target(name: .cottonBase),
                .target(name: .autoMockableKit),
                .product(name: .reactiveSwiftFramework, package: .reactiveSwiftFramework),
                .product(name: .swXmlHashFramework, package: .swXmlHashFramework),
                .product(name: .alamofireFramework, package: .alamofireFramework)
            ]
        ),
        .binaryTarget(
            name: .cottonBase,
            path: "../../cotton-base/build/XCFrameworks/release/CottonBase.xcframework"
        ),
        .testTarget(
            name: "BaseTests",
            dependencies: [
                .target(name: .basePackage)
            ]
        ),
        .testTarget(
            name: "CottonRestKitTests",
            dependencies: [
                .target(name: .cottonRestKit)
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
