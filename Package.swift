// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Nomad",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Nomad",
            targets: ["Nomad"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/mxcl/Version.git", from: "2.0.0"),
        .package(url: "https://github.com/mxcl/PromiseKit", from: "6.8.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Nomad",
            dependencies: [
                "PromiseKit",
                "Version",
            ]),
        .testTarget(
            name: "NomadTests",
            dependencies: ["Nomad"]),
    ],
    swiftLanguageVersions: [.v5]
)
