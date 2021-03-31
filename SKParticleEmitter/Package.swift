// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SKParticleEmitter",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SKParticleEmitter",
            targets: ["SKParticleEmitter"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "XMLCoder", url: "https://github.com/MaxDesiatov/XMLCoder.git", from: "0.12.0"),
        .package(name: "Gzip", url: "https://github.com/1024jp/GzipSwift", from: "5.1.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SKParticleEmitter",
            dependencies: ["Gzip", "XMLCoder"])
//        .testTarget(
//            name: "SKParticleEmitterTests",
//            dependencies: ["SKParticleEmitter"]),
    ]
)
