// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "ElasticsearchService",
    products: [
        .library(name: "ElasticsearchService", targets: ["ElasticsearchService"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        .package(url: "https://github.com/skelpo/JSON.git", from: "0.1.3")
    ],
    targets: [
        .target(name: "ElasticsearchService", dependencies: ["JSON", "Vapor"]),
        .testTarget(name: "ElasticsearchServiceTests", dependencies: ["ElasticsearchService"])
    ]
)
