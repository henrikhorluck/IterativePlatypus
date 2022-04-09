// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "IterativePlatypus",
    platforms: [
        // the whole purpose of this program is to interface with a user's Apple Photos library
        // anything other than macOS makes no sense, sadly
        .macOS(.v12),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    ],
    targets: [
        // https://github.com/apple/swift-package-manager/blob/main/Documentation/Usage.md#requiring-system-libraries
        .systemLibrary(
            name: "CMagickWand",
            pkgConfig: "MagickWand",
            providers: [
                .brew(["imagemagick@7"]),
            ]
        ),
        .executableTarget(
            name: "IterativePlatypus",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Logging", package: "swift-log"),
                .target(name: "CMagickWand"),
            ]
        ),

        .testTarget(
            name: "IterativePlatypusTests",
            dependencies: ["IterativePlatypus"],
            resources: [
                .copy("test.jpeg"),
            ]
        ),
    ]
)
