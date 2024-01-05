// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FLiveSDK-iOS",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "FLiveSDK-iOS",
            targets: ["FLiveSDK-iOS", "FLiveSDK"]),
    ],
    dependencies: [
        .package(url: "https://github.com/robbiehanson/CocoaAsyncSocket", branch: "master"),
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "FLiveSDK-iOS",
            dependencies: [
                .product(name: "CocoaAsyncSocket", package: "CocoaAsyncSocket"),
            ]),
        .testTarget(
            name: "FLiveSDK-iOSTests",
            dependencies: ["FLiveSDK-iOS"]),
        .binaryTarget(name: "FLiveSDK", path: "./Sources/FLiveSDK.xcframework"),
    ]
)
