//
//  BarChartViewModel.swift
//  KitoCharts
//
//  Created by Wycliff on 1/18/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import Observation
import KitoCore

/// Owns bar-chart state: data, which bar is highlighted, and per-bar grow-in
/// progress for the entrance animation. Supports grouped bars via `category`.
@Observable
public final class BarChartViewModel: KitoViewModel {
    public var points: [ChartDataPoint]
    public var highlightedPointID: ChartDataPoint.ID?
    public var growProgress: Double = 0
    public var isHorizontal: Bool

    public init(points: [ChartDataPoint], isHorizontal: Bool = false) {
        self.points = points
        self.isHorizontal = isHorizontal
    }

    public var groupedByLabel: [(label: String, points: [ChartDataPoint])] {
        var seen = Set<String>()
        var order: [String] = []
        for point in points where seen.insert(point.label).inserted {
            order.append(point.label)
        }
        return order.map { label in (label, points.filter { $0.label == label }) }
    }

    public func highlight(_ id: ChartDataPoint.ID?) {
        highlightedPointID = id
    }

    public func grow(duration: Double) {
        growProgress = 0
        withAnimation(.spring(response: duration, dampingFraction: 0.8)) {
            growProgress = 1
        }
    }
}
