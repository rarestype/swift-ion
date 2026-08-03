// swift-tools-version:6.3
import PackageDescription

let package: Package = .init(
    name: "swift-ion",
    platforms: [.macOS(.v15), .iOS(.v18), .tvOS(.v18), .visionOS(.v2), .watchOS(.v11)],
    products: [
        .library(name: "Ion", targets: ["Ion"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ordo-one/dollup", from: "1.0.1"),
        .package(url: "https://github.com/ordo-one/lexic", from: "1.7.0"),
    ],
    targets: [
        .target(
            name: "Ion",
            dependencies: [
                .target(name: "IonABI"),
            ]
        ),

        .target(
            name: "IonABI",
            dependencies: [
                .product(name: "Bijection", package: "lexic"),
            ],
        ),

        .testTarget(
            name: "IonTests",
            dependencies: [
                .target(name: "Ion"),
                .product(name: "Bijection", package: "lexic"),
            ]
        ),
    ]
)

for target: Target in package.targets {
    {
        var settings: [SwiftSetting] = $0 ?? []

        settings.append(.enableUpcomingFeature("ExistentialAny"))
        settings.append(.enableUpcomingFeature("MemberImportVisibility"))
        settings.append(.enableUpcomingFeature("InternalImportsByDefault"))
        settings.append(.enableExperimentalFeature("StrictConcurrency"))

        $0 = settings
    } (&target.swiftSettings)
}
