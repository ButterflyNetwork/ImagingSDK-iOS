// swift-tools-version:5.9

import PackageDescription

// Release: https://github.com/ButterflyNetwork/ButterflySDKIOS/releases/tag/1.2.2
let binaryUrl = "https://sdk.butterflynetwork.com/garden/ButterflyImagingKit/1.2.2/ButterflyImagingKit.xcframework.zip"
let binaryChecksum = "9726bddcd5566173961bde4e180dae7ac6e32b9fa73bca781cf331a6e53eebd5"

let package = Package(
    name: "Butterfly",
    platforms: [
        .iOS(.v16),
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
