// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Mustache",
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
                .process("vendor")  // mustache specs
            ]
        )
    ]
) 
