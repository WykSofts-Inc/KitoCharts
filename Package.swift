// swift-tools-version: 5.9
//
//  Package.swift
//  KitoCharts
//
//  Created by Wycliff on 1/12/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//


import PackageDescription

let package = Package(
    name: "KitoCharts",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "KitoCharts", targets: ["KitoCharts"]),
    ],
    dependencies: [
        .package(url: "https://github.com/WykSofts-Inc/KitoCore.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "KitoCharts",
            dependencies: [
                .product(name: "KitoCore", package: "KitoCore"),
            ]
        ),
        .testTarget(name: "KitoChartsTests", dependencies: ["KitoCharts"]),
    ]
)
