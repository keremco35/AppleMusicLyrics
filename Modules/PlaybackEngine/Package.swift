// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "PlaybackEngine",
    platforms: [.iOS(.v16)],
    products: [.library(name: "PlaybackEngine", targets: ["PlaybackEngine"])],
    dependencies: [.package(path: "../LyricsEngine")],
    targets: [.target(name: "PlaybackEngine", dependencies: ["LyricsEngine"])]
)
