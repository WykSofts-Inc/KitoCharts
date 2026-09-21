//
//  ChartTheme.swift
//  KitoCharts
//
//  Created by Wycliff on 1/14/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore

/// Chart-specific presentation on top of `KitoTheme`. Every chart view reads
/// this via `@Environment(\.kitoChartTheme)` instead of declaring its own
/// palette — a consumer overriding `categoricalPalette` retints every chart
/// type at once.
public struct KitoChartTheme: Equatable, Sendable {
    public var categoricalPalette: [Color]
    public var gridlineColor: Color
    public var axisColor: Color
    public var axisLabelColor: Color
    public var showGridlines: Bool
    public var animationDuration: Double

    public init(
        categoricalPalette: [Color] = KitoChartTheme.defaultPalette,
        gridlineColor: Color = Color.gray.opacity(0.15),
        axisColor: Color = Color.gray.opacity(0.4),
        axisLabelColor: Color = .secondary,
        showGridlines: Bool = true,
        animationDuration: Double = 0.6
    ) {
        self.categoricalPalette = categoricalPalette
        self.gridlineColor = gridlineColor
        self.axisColor = axisColor
        self.axisLabelColor = axisLabelColor
        self.showGridlines = showGridlines
        self.animationDuration = animationDuration
    }

    /// Color for the nth category, wrapping around the palette. Charts never
    /// index the palette array directly, so a 9-series chart over a 6-color
    /// palette still renders instead of crashing.
    public func color(forCategoryIndex index: Int) -> Color {
        categoricalPalette[index % categoricalPalette.count]
    }

    public static let defaultPalette: [Color] = [
        Color(red: 0.11, green: 0.42, blue: 0.94),
        Color(red: 0.96, green: 0.55, blue: 0.16),
        Color(red: 0.13, green: 0.66, blue: 0.42),
        Color(red: 0.82, green: 0.24, blue: 0.42),
        Color(red: 0.55, green: 0.36, blue: 0.94),
        Color(red: 0.13, green: 0.66, blue: 0.78),
    ]

    public static let `default` = KitoChartTheme()
}

private struct KitoChartThemeKey: EnvironmentKey {
    static let defaultValue: KitoChartTheme = .default
}

public extension EnvironmentValues {
    var kitoChartTheme: KitoChartTheme {
        get { self[KitoChartThemeKey.self] }
        set { self[KitoChartThemeKey.self] = newValue }
    }
}

public extension View {
    func kitoChartTheme(_ theme: KitoChartTheme) -> some View {
        environment(\.kitoChartTheme, theme)
    }
}
