// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "UIComponents",
    platforms: [.iOS(.v16)],
    products: [.library(name: "UIComponents", targets: ["UIComponents"])],
    dependencies: [.package(path: "../LyricsEngine")],
    targets: [.target(name: "UIComponents", dependencies: ["LyricsEngine"])]
)
