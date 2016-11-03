import PackageDescription

let package = Package(
  name: "Mustache",
  dependencies: [
    .Package(url: "https://github.com/IBM-Swift/Bridging.git", majorVersion: 1, minor: 1),
    //TODO make this test dependency once issue https://bugs.swift.org/browse/SR-883 is resolved
      .Package(url: "https://github.com/IBM-Swift/SwiftyJSON.git", majorVersion: 15, minor: 0)
  ],
  exclude: ["Tests/Carthage", "Tests/vendor", "Tests/Info.plist"]
)
