// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BeaconRuntime",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "BeaconRuntime",
            path: "Sources/BeaconRuntime",
            resources: [
                .copy("Resources")
            ]
        ),
        .testTarget(
            name: "BeaconRuntimeTests",
            dependencies: ["BeaconRuntime"],
            path: "Tests/BeaconRuntimeTests"
        )
    ]
)
