// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ProjectStructureKit",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ProjectStructureKit",
            targets: ["ProjectStructureKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/JohnSundell/ShellOut.git", from: "2.3.0"),
        .package(url: "https://github.com/kylef/PathKit.git", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ProjectStructureKit",
            dependencies: [
                "ShellOut",
                "PathKit"
            ]),
        .testTarget(
            name: "ProjectStructureKitTests",
            dependencies: ["ProjectStructureKit"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
