// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FileNavigation",
    platforms: [
      // Only add support for iOS 16 and up.
      .iOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "FileNavigation",
            targets: ["FileNavigation"]),
    ],
    dependencies: [
        .package(name: "APIClient", path: "../APIClient"),
        .package(name: "AsyncView", path: "../AsyncView"),
        .package(name: "FileModels", path: "../FileModels"),
        .package(name: "FileRepository", path: "../FileRepository"),
        .package(name: "NavigationRouter", path: "../NavigationRouter")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "FileNavigation",
            dependencies: ["APIClient", "AsyncView", "FileModels", "FileRepository", "NavigationRouter"]
            ),
        .testTarget(
            name: "FileNavigationTests",
            dependencies: ["FileNavigation"]),
    ]
)
