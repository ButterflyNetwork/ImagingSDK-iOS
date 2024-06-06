// swift-tools-version:5.9

import PackageDescription

// Release: https://github.com/ButterflyNetwork/ImagingSDK-iOS/releases/tag/1.2.1
let binaryUrl = "https://sdk.butterflynetwork.com/garden/ButterflyImagingKit/1.2.1/ButterflyImagingKit.xcframework.zip"
let binaryChecksum = "2d3c88f8058b821b162a6364592cc2fd2d94f134209ebe31de9afe2c4fc515d1"

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
