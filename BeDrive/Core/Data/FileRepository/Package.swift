// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FileRepository",
    platforms: [
      // Only add support for iOS 15 and up.
      .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "FileRepository",
            targets: ["FileRepository"]),
    ],
    dependencies: [
        .package(name: "APIClient", path: "../APIClient"),
        .package(name: "DataCache", path: "../DataCache"),
        .package(name: "FileCache", path: "../FileCache"),
        .package(name: "FileModels", path: "../FileModels")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "FileRepository",
            dependencies: ["APIClient", "DataCache", "FileCache", "FileModels"]),
        .testTarget(
            name: "FileRepositoryTests",
            dependencies: ["FileRepository"]),
    ]
)
