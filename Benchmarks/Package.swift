// swift-tools-version:6.3
import PackageDescription

let package: Package = .init(
    name: "benchmarks",
    platforms: [.macOS(.v15), .iOS(.v18), .tvOS(.v18), .visionOS(.v2), .watchOS(.v11)],
    products: [
        .executable(name: "IonBenchmarks", targets: ["IonBenchmarks"]),
    ],
    dependencies: [
        .package(path: ".."),
        .package(url: "https://github.com/ordo-one/package-benchmark", from: "1.28.0"),
    ],
    targets: [
        .executableTarget(
            name: "IonBenchmarks",
            dependencies: [
                .product(name: "Ion", package: "swift-ion"),
                .product(name: "Benchmark", package: "package-benchmark"),
            ],
            path: "IonBenchmarks",
            plugins: [
                .plugin(name: "BenchmarkPlugin", package: "package-benchmark"),
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
