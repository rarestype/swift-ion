// swift-tools-version:6.3
import class Foundation.ProcessInfo
import PackageDescription

var BuildLibraryAsBinary: Bool {
    switch ProcessInfo.processInfo.environment["BUILD_LIBRARY_AS_BINARY"] {
    case "true"?: true
    case "1"?: true
    default: false
    }
}

let package: Package = .init(
    name: "swift-ion",
    platforms: [.macOS(.v15), .iOS(.v18), .tvOS(.v18), .visionOS(.v2), .watchOS(.v11)],
    products: [
        "Ion",
        "IonABI",
        "IonText",
    ].map {
        .library(name: $0, type: BuildLibraryAsBinary ? .dynamic : nil, targets: [$0])
    },
    dependencies: [
        .package(url: "https://github.com/ordo-one/dollup", from: "1.0.1"),
        .package(url: "https://github.com/ordo-one/lexic", from: "1.7.0"),
        .package(url: "https://github.com/rarestype/gram", from: "2.1.0"),
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

        .target(
            name: "IonText",
            dependencies: [
                .target(name: "IonABI"),
                .product(name: "Grammar", package: "gram"),
            ],
        ),

        .testTarget(
            name: "IonTests",
            dependencies: [
                .target(name: "Ion"),
                .target(name: "IonText"),
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

        if BuildLibraryAsBinary {
            settings.append(
                .unsafeFlags(
                    ["-enable-library-evolution", "-emit-module-interface"],
                    .when(platforms: [.linux])
                )
            )
        }

        $0 = settings
    } (&target.swiftSettings)
}
