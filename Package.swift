import PackageDescription

let package = Package(
  name: "Mustache",
  testDependencies: [
    .Package(url: "git@github.com:IBM-Swift/Kitura-TestFramework.git", majorVersion: 0)
  ]
) 
