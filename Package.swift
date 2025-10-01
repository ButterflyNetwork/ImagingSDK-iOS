// swift-tools-version:5.9

import PackageDescription

// Release: https://github.com/ButterflyNetwork/ButterflySDKIOS/releases/tag/2.0.2
let binaryUrl = "https://sdk.butterflynetwork.com/garden/ButterflyImagingKit/2.0.2/ButterflyImagingKit.xcframework.zip"
let binaryChecksum = "7428b83c858d0cb8b13fefd2bb8b329df1b1100c10a1d4803eed5612530d2d74"

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
