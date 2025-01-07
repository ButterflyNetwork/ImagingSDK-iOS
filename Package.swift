// swift-tools-version:5.9

import PackageDescription

// Release: https://github.com/ButterflyNetwork/ButterflySDKIOS/releases/tag/1.2.3
let binaryUrl = "https://sdk.butterflynetwork.com/garden/ButterflyImagingKit/1.2.3/ButterflyImagingKit.xcframework.zip"
let binaryChecksum = "aafa340a3224a9c0c8af3ff040ac9d6d1792bde11b2cc9095a26e62deba9edef"

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
