// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "HabitMon",
    platforms: [.macOS(.v13)],
    targets: [
        .target(
            name: "HabitMonCore"
        ),
        .executableTarget(
            name: "HabitMon",
            dependencies: ["HabitMonCore"]
        ),
        .testTarget(
            name: "HabitMonCoreTests",
            dependencies: ["HabitMonCore"]
        ),
    ]
)
