// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ClaudeTaskMenuBar",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "ClaudeTaskMenuBar",
            path: "Sources/ClaudeTaskMenuBar"
        )
    ]
)
