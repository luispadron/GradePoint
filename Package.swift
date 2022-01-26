// swift-tools-version:5.5.0

import PackageDescription

let package = Package(
    name: "GradePoint",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
    ],
    products: [
        .library(name: "GradePointUI", targets: ["GradePointUI"]),
        .library(name: "GradePointDomain", targets: ["GradePointDomain"]),
        .library(name: "GradePointModel", targets: ["GradePointModel"]),
    ],
    dependencies: [
        .package(name: "Realm", url: "https://github.com/realm/realm-swift.git", .upToNextMajor(from: "10.0.0")),
    ],
    targets: [
        .target(
            name: "GradePointUI",
            dependencies: [
                "GradePointDomain"
            ]
        ),
        .target(
            name: "GradePointDomain",
            dependencies: [
                "GradePointModel",
                .product(name: "RealmSwift", package: "Realm"),
            ]
        ),
        .target(
            name: "GradePointModel",
            dependencies: [
                .product(name: "RealmSwift", package: "Realm"),
            ]
        )
    ]
)