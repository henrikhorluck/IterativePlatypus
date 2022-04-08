// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "photo-export",
  platforms: [
    // the whole purpose of this program is to interface with a user's Apple Photos library
    // anything other than macOS makes no sense, sadly
    .macOS("11")
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
  ],
  targets: [
    .systemLibrary(
      name: "MagickWand",
      pkgConfig: "MagickWand",
      providers: [
        .brew(["imagemagick"])
      ]
    ),
    .executableTarget(
      name: "photo-export",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "Logging", package: "swift-log"),
        .target(name: "MagickWand"),
      ],
      cSettings: [
        .headerSearchPath(""),
        .unsafeFlags([
          // "-Xpreprocessor",
          // "-fopenmp",
          "-DMAGICKCORE_HDRI_ENABLE=1",
          "-DMAGICKCORE_QUANTUM_DEPTH=16",
        ]),
      ]
    ),

    .testTarget(
      name: "photo-exportTests",
      dependencies: ["photo-export"]
    ),
  ]
)
