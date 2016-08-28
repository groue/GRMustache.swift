import PackageDescription

let package = Package(
  name: "Mustache",
  dependencies: [
    .Package(url: "https://github.com/IBM-Swift/Bridging.git", majorVersion: 0, minor: 29),
    //TODO make this test dependency once issue https://bugs.swift.org/browse/SR-883 is resolved
      .Package(url: "https://github.com/IBM-Swift/SwiftyJSON.git", majorVersion: 12, minor: 1)
  ],
  exclude: ["Tests/Carthage", "Tests/vendor", "Tests/Info.plist"]
)
