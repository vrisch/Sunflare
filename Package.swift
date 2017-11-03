// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Sunflare",
    products: [
        .library(
            name: "Sunflare",
            targets: ["Sunflare"]),
        ],
    dependencies: [
        .package(url: "https://github.com/vrisch/Orbit.git", .branch("develop")),
        ],
    targets: [
        .target(
            name: "Sunflare",
            dependencies: ["Orbit"]),
        ]
)
