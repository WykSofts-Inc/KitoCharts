//
//  LineChartViewModel.swift
//  KitoCharts
//
//  Created by Wycliff on 1/20/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import Observation
import KitoCore

/// Owns line-chart state: the data, per-series grouping, which point (if any)
/// is under the user's finger, and reveal progress for the draw-in animation.
/// The view reads this and never computes a path itself.
@Observable
public final class LineChartViewModel: KitoViewModel {
    public var points: [ChartDataPoint]
    public var selectedPointID: ChartDataPoint.ID?
    public var revealProgress: Double = 0
    public var isSmoothed: Bool

    public init(points: [ChartDataPoint], isSmoothed: Bool = true) {
        self.points = points
        self.isSmoothed = isSmoothed
    }

    public var series: [(category: String, points: [ChartDataPoint])] {
        points.categories.map { category in
            (category, points.filter { $0.category == category })
        }
    }

    public var selectedPoint: ChartDataPoint? {
        guard let id = selectedPointID else { return nil }
        return points.first { $0.id == id }
    }

    public func select(pointNear location: CGPoint, in points: [ChartDataPoint], xScale: LinearScale) {
        guard !points.isEmpty else { selectedPointID = nil; return }
        let nearest = points.enumerated().min { lhs, rhs in
            let lhsX = xScale.scale(Double(lhs.offset))
            let rhsX = xScale.scale(Double(rhs.offset))
            return abs(lhsX - location.x) < abs(rhsX - location.x)
        }
        selectedPointID = nearest?.element.id
    }

    public func clearSelection() {
        selectedPointID = nil
    }

    public func reveal(duration: Double) {
        revealProgress = 0
        withAnimation(.easeOut(duration: duration)) {
            revealProgress = 1
        }
    }
}
