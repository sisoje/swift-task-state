// swift-tools-version: 6.3
import PackageDescription

let package = Package(
    name: "TaskState",
    platforms: [
        .macOS(.v26), .iOS(.v26), .tvOS(.v26), .watchOS(.v26),
        .visionOS(.v26), .macCatalyst(.v26),
    ],
    products: [
        .library(name: "TaskState", targets: ["TaskState"]),
    ],
    targets: [
        .target(name: "TaskState"),

        // A runnable SwiftUI demo: `swift run TaskStateExample`.
        .executableTarget(
            name: "TaskStateExample",
            dependencies: ["TaskState"]
        ),

        .testTarget(
            name: "TaskStateTests",
            dependencies: ["TaskState"]
        ),
    ]
)
