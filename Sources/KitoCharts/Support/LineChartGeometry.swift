//
//  LineChartGeometry.swift
//  KitoCharts
//
//  Created by Wycliff on 9/23/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI

/// The pure geometry behind `LineChartView`: kept out of the view so it can be unit-tested.
enum LineChartGeometry {
    /// The value domain the chart plots: the data, stretched to include every reference line and,
    /// when asked, zero.
    static func domain(for points: [ChartDataPoint], style: LineChartStyle) -> ClosedRange<Double> {
        let base = points.valueRange
        var lower = base.lowerBound
        var upper = base.upperBound
        for line in style.referenceLines {
            lower = min(lower, line.value)
            upper = max(upper, line.value)
        }
        if style.includesZero || style.area != .none {
            lower = min(lower, 0)
            upper = max(upper, 0)
        }
        return lower == upper ? (lower - 1)...(upper + 1) : lower...upper
    }

    /// The line through `points` using `interpolation`.
    static func linePath(through points: [CGPoint], interpolation: LineInterpolation) -> Path {
        Path { path in
            guard let first = points.first else { return }
            path.move(to: first)
            guard points.count > 1 else { return }

            for index in 1..<points.count {
                let previous = points[index - 1]
                let current = points[index]
                switch interpolation {
                case .linear:
                    path.addLine(to: current)
                case .smooth:
                    let midX = (previous.x + current.x) / 2
                    path.addCurve(to: current, control1: CGPoint(x: midX, y: previous.y), control2: CGPoint(x: midX, y: current.y))
                case .catmullRom:
                    let before = points[max(index - 2, 0)]
                    let after = points[min(index + 1, points.count - 1)]
                    let control1 = CGPoint(x: previous.x + (current.x - before.x) / 6, y: previous.y + (current.y - before.y) / 6)
                    let control2 = CGPoint(x: current.x - (after.x - previous.x) / 6, y: current.y - (after.y - previous.y) / 6)
                    path.addCurve(to: current, control1: control1, control2: control2)
                case .stepped:
                    path.addLine(to: CGPoint(x: current.x, y: previous.y))
                    path.addLine(to: current)
                }
            }
        }
    }

    /// The line closed down to `baselineY`, for an area fill.
    static func areaPath(through points: [CGPoint], interpolation: LineInterpolation, baselineY: CGFloat) -> Path {
        guard let first = points.first, let last = points.last else { return Path() }
        var path = linePath(through: points, interpolation: interpolation)
        path.addLine(to: CGPoint(x: last.x, y: baselineY))
        path.addLine(to: CGPoint(x: first.x, y: baselineY))
        path.closeSubpath()
        return path
    }

    /// Which point indices get an x-axis label: every one when they fit, otherwise every nth,
    /// always including the last so the latest period is labelled.
    static func labelIndices(count: Int, width: CGFloat, minimumSpacing: CGFloat = 34) -> [Int] {
        guard count > 0 else { return [] }
        guard count > 1, width > 0 else { return [0] }
        let spacing = width / CGFloat(count - 1)
        let stride = max(Int((minimumSpacing / spacing).rounded(.up)), 1)
        var indices = Array(Swift.stride(from: 0, to: count, by: stride))
        if indices.last != count - 1 {
            // Drop the final stride label if it would crowd the last one.
            if let lastLabelled = indices.last, CGFloat(count - 1 - lastLabelled) * spacing < minimumSpacing {
                indices.removeLast()
            }
            indices.append(count - 1)
        }
        return indices
    }
}
