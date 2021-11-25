// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "CornSnpshotTesting",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "CornSnapshotTesting",
            targets: ["CornSnapshotTesting"]),
    ],
    targets: [
        .target(
            name: "CornSnapshotTesting",
            dependencies: []),
        .testTarget(
            name: "CornSnapshotTestingTests",
            dependencies: ["CornSnapshotTesting"]),
    ]
)
