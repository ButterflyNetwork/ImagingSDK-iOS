// swift-tools-version:5.9

import PackageDescription

// Release: https://github.com/ButterflyNetwork/ButterflySDKIOS/releases/tag/2.1.0
let binaryUrl = "https://sdk.butterflynetwork.com/garden/ButterflyImagingKit/2.1.0/ButterflyImagingKit.xcframework.zip"
let binaryChecksum = "432317e84f2083783797215509e2b268e04e093d35a2effbef31b99710c0c1f3"

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
