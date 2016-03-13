import PackageDescription

let package = Package(
  name: "Mustache",
  dependencies: [
    .Package(url: "https://github.com/IBM-Swift/Bridging.git", majorVersion: 0, minor: 2)
  ]
)
