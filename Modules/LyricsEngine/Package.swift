// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "LyricsEngine",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "LyricsEngine", targets: ["LyricsEngine"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "LyricsEngine", dependencies: []),
        .testTarget(name: "LyricsEngineTests", dependencies: ["LyricsEngine"]),
    ]
)
