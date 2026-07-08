// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "BrickCritterBuildsSupport",
    platforms: [.iOS(.v17)],
    products: [.library(name: "BrickCritterBuildsSupport", targets: ["BrickCritterBuildsSupport"])],
    targets: [.target(name: "BrickCritterBuildsSupport", path: "BrickCritterBuildsSupport")]
)
