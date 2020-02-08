// swift-tools-version:5.1
import PackageDescription

let package = Package(
  name: "SwiftEndpoint",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15)
  ],
  products: [
    .library(name: "SwiftEndpoint", targets: ["SwiftEndpoint"]),
  ],
  targets: [
    .target(name: "SwiftEndpoint", dependencies: []),
    .testTarget(name: "SwiftEndpointTests", dependencies: ["SwiftEndpoint"]),
  ]
)
