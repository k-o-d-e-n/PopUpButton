// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "PopUpButton",
    platforms: [.iOS(.v11)],
    products: [
        .library(
            name: "PopUpButton",
            targets: ["PopUpButton"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "PopUpButton",
            dependencies: []
        )
    ]
)
