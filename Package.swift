// swift-tools-version:5.9

import PackageDescription

// Release: https://github.com/ButterflyNetwork/ButterflySDKIOS/releases/tag/2.0.1
let binaryUrl = "https://sdk.butterflynetwork.com/garden/ButterflyImagingKit/2.0.1/ButterflyImagingKit.xcframework.zip"
let binaryChecksum = "a74b41700b54418528998db6b95598a08a77a0597449db237497dc7ea2843f9e"

let package = Package(
    name: "Butterfly",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "ButterflyImagingKit",
            targets: ["ButterflyImagingKit"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "ButterflyImagingKit",
            url: binaryUrl,
            checksum: binaryChecksum
        ),
    ]
)
