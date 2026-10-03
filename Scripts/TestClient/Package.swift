// swift-tools-version: 6.3
import PackageDescription

let package: Package = .init(
    name: "swift-ion-test-client",
    products: [
    ],
    targets: [
        .target(
            name: "Consumer",
            dependencies: [
                .target(name: "Ion"),
                .target(name: "IonABI"),
                .target(name: "IonText"),
            ]
        ),

        binary(name: "Ion"),
        binary(name: "IonABI"),
        binary(name: "IonText"),
    ]
)

func binary(name: String) -> Target {
    return .binaryTarget(name: name, path: "../../.build/xcframeworks_/\(name).xcframework")
}
