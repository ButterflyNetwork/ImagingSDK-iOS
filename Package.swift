// swift-tools-version:5.9

import PackageDescription

// Release: https://github.com/ButterflyNetwork/ButterflySDKIOS/releases/tag/2.0.0
let binaryUrl = "https://sdk.butterflynetwork.com/garden/ButterflyImagingKit/2.0.0/ButterflyImagingKit.xcframework.zip"
let binaryChecksum = "921f8dbce9d7d448a9322f4449297e85c3c42b214e9489018a9523166d726023"

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
