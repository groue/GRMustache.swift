// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Mustache",
    platforms: [
        .iOS(.v8),
        .macOS(.v10_10),
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
            dependencies: [],
            path: "Sources"
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
