// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "Mustache",
    platforms: [
        .iOS(.v11),
        .macOS(.v10_11),
        .tvOS(.v9)
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
