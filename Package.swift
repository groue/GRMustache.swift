import PackageDescription

let swiftyJsonUrl = "https://github.com/IBM-Swift/SwiftyJSON.git"
let swiftyJsonVersion = 12

let package = Package(
  name: "Mustache",
  dependencies: [
    .Package(url: "https://github.com/IBM-Swift/Bridging.git", majorVersion: 0, minor: 2),
    //TODO make this test dependency once issue https://bugs.swift.org/browse/SR-883 is resolved
    .Package(url: swiftyJsonUrl, majorVersion: swiftyJsonVersion)
  ],
  exclude: ["Tests/Carthage", "Tests/vendor", "Tests/Info.plist"]
)
