// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-standard-library-extensions",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(name: "Standard Library Extensions", targets: ["Standard Library Extensions"]),
        .library(name: "Standard Library Extensions Standard Library Integration", targets: ["Standard Library Extensions Standard Library Integration"]),
        .library(name: "Standard Library Extensions Foundation Library Integration", targets: ["Standard Library Extensions Foundation Library Integration"]),
        .library(name: "Standard Library Extensions Test Support", targets: ["Standard Library Extensions Test Support"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Standard Library Extensions",
            dependencies: [
            ],
            path: "Sources/Standard Library Extensions"
        ),
        .target(
            name: "Standard Library Extensions Standard Library Integration",
            dependencies: [
                .target(name: "Standard Library Extensions"),
            ],
            path: "Sources/Standard Library Extensions Standard Library Integration"
        ),
        .target(
            name: "Standard Library Extensions Foundation Library Integration",
            dependencies: [
                .target(name: "Standard Library Extensions"),
                .target(name: "Standard Library Extensions Standard Library Integration"),
            ],
            path: "Sources/Standard Library Extensions Foundation Library Integration"
        ),
        .target(
            name: "Standard Library Extensions Test Support",
            dependencies: [
                .target(name: "Standard Library Extensions"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Standard Library Extensions Tests",
            dependencies: [
                .target(name: "Standard Library Extensions"),
                .target(name: "Standard Library Extensions Test Support"),
                .target(name: "Standard Library Extensions Standard Library Integration"),
                .target(name: "Standard Library Extensions Foundation Library Integration"),
            ],
            path: "Tests/Standard Library Extensions Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets {
    target.swiftSettings = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]
}
