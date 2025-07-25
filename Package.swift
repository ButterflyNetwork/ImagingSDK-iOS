// swift-tools-version:5.9

import PackageDescription

// Release: https://github.com/ButterflyNetwork/ButterflySDKIOS/releases/tag/2.0.0-beta.1
let binaryUrl = "https://sdk.butterflynetwork.com/garden/ButterflyImagingKit/2.0.0-beta.1/ButterflyImagingKit.xcframework.zip"
let binaryChecksum = "04907fc227d95730fb9f50ca7073f28bf3c5fd8bc918e5b347b246bea2cb9250"

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
