// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "Mustache",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_13),
        .tvOS(.v12)
    ],
    products: [
        .library(
            name: "Mustache",
            targets: ["Mustache"]
        )
    ],
    targets: [
        .target(
            name: "Mustache",
            dependencies: ["GRMustacheKeyAccess"],
            path: "Sources",
            swiftSettings: [
                .define("OBJC")
            ]
        ),
        .target(
            name: "GRMustacheKeyAccess",
            path: "ObjC",
            sources: ["GRMustacheKeyAccess.m"],
            publicHeadersPath: "."
        ),
        .testTarget(
            name: "MustacheTests",
            dependencies: [
                "Mustache"
            ],
            path: "Tests",
            exclude: [
                "Carthage"
            ],
            resources: [
                .process("Public/ServicesTests/LocalizerTestsBundle"), // localized strings
                .process("vendor"),  // mustache specs
                .process("Public/SuitesTests/twitter/HoganSuite") // Hogan specs
            ]
        )
    ]
) 
