import PackageDescription

#if os(Linux)
    let swiftyJsonUrl = "https://github.com/IBM-Swift/SwiftyJSON.git"
    let swiftyJsonVersion = 3
#else
     let swiftyJsonUrl = "https://github.com/SwiftyJSON/SwiftyJSON.git"
     let swiftyJsonVersion = 2
#endif

let package = Package(
  name: "Mustache",
  dependencies: [
    .Package(url: "https://github.com/IBM-Swift/Bridging.git", majorVersion: 0, minor: 2),
    //TODO make this test dependency once issue https://bugs.swift.org/browse/SR-883 is resolved
    .Package(url: swiftyJsonUrl, majorVersion: swiftyJsonVersion)
  ]
)
