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
        .library(
            name: "Standard Library Extensions",
            targets: ["Standard Library Extensions"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Standard Library Extensions"
        ),
        .testTarget(
            name: "Standard Library Extensions Tests",
            dependencies: [
                .target(name: "Standard Library Extensions"),
            ]
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
