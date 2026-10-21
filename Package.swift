// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Orbyt",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "Orbyt", targets: ["Orbyt"]),
        .executable(name: "obt", targets: ["obt"]),
        .library(name: "HerdrKit", targets: ["HerdrKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Lakr233/libghostty-spm.git", exact: "1.6.20260929"),
    ],
    targets: [
        .target(name: "HerdrKit"),
        .executableTarget(
            name: "Orbyt",
            dependencies: [
                "HerdrKit",
                .product(name: "GhosttyTerminal", package: "libghostty-spm"),
            ],
            // Ghostty's theme collection (iTerm2-Color-Schemes, MIT), for
            // `theme = <name>` in the user's Ghostty config.
            resources: [.copy("Resources/ghostty-themes")]
        ),
        .executableTarget(name: "obt", dependencies: ["HerdrKit"]),
        .testTarget(name: "HerdrKitTests", dependencies: ["HerdrKit"]),
        .testTarget(name: "OrbytTests", dependencies: ["Orbyt"]),
    ]
)
