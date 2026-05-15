// swift-tools-version:5.9

import PackageDescription

// Release: https://github.com/ButterflyNetwork/ButterflySDKIOS/releases/tag/2.1.0
let binaryUrl = "https://sdk.butterflynetwork.com/garden/ButterflyImagingKit/2.1.0/ButterflyImagingKit.xcframework.zip"
let binaryChecksum = "7b021af473713a95b65fd2e818de86dcc385cdd78ea20659167c4fe4d069456e"

let package = Package(
    name: "Butterfly",
    platforms: [
        .iOS("18.0"),
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
