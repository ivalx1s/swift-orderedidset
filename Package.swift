// swift-tools-version: 6.0

import PackageDescription

let package = Package(
	name: "swift-orderedidset",
	platforms: [
		.iOS(.v13),
		.macOS(.v10_15),
		.tvOS(.v13),
		.watchOS(.v6)
	],
	products: [
		.library(
			name: "OrderedIDSet",
			targets: ["OrderedIDSet"]
		),
	],
	dependencies:      [
        .package(
            url: "git@github.com:apple/swift-collections.git",
            .upToNextMajor(from: "1.1.4")
        ),
	],
	targets: [
		.target(
			name: "OrderedIDSet",
			dependencies:  [
                .product(name: "OrderedCollections", package: "swift-collections"),
			]
		),
        .target(
            name: "OrderedIDSetTests"
        ),
	]
)
