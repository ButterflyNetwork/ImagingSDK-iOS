// swift-tools-version:5.9

import PackageDescription

// Release: https://github.com/ButterflyNetwork/ButterflySDKIOS/releases/tag/2.0.3
let binaryUrl = "https://sdk.butterflynetwork.com/garden/ButterflyImagingKit/2.0.3/ButterflyImagingKit.xcframework.zip"
let binaryChecksum = "3fc1a1826f227363c95feacf2d4f8b84e22c778796b445c5a0499e6b51008244"

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
