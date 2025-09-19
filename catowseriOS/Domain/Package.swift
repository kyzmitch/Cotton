// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// MARK: - Identifiers

private extension String {
    
    // MARK: - Root
    
    static let domainPackage = "Domain"
    static let basePackage = "Base"
    
    // MARK: - Libraries
    
    // MARK: - Frameworks/Kits
    
    static let genericServiceKit = "GenericServiceKit"
    static let baseUseCaseKit = "BaseUseCaseKit"
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
