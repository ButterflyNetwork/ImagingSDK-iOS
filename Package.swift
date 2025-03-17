// swift-tools-version:5.9

import PackageDescription

// Release: https://github.com/ButterflyNetwork/ButterflySDKIOS/releases/tag/1.2.4
let binaryUrl = "https://sdk.butterflynetwork.com/garden/ButterflyImagingKit/1.2.4/ButterflyImagingKit.xcframework.zip"
let binaryChecksum = "a227994a35e8748f36b4d1d5ae63c6900e3d509ff712ed3d353af8904cdef9ab"

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
