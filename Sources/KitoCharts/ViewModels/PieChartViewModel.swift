//
//  PieChartViewModel.swift
//  KitoCharts
//
//  Created by Wycliff on 1/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import Observation
import KitoCore

public struct PieSlice: Identifiable {
    public let id: ChartDataPoint.ID
    public let point: ChartDataPoint
    public let startAngle: Angle
    public let endAngle: Angle
    public let fraction: Double
}

/// Owns pie/donut state: converts values into angular slices, tracks the
/// selected slice, and exposes `innerRadiusFraction` so one view model drives
/// both a pie (`0`) and a donut (`> 0`) — donut-ness is configuration, not a
/// separate type.
@Observable
public final class PieChartViewModel: KitoViewModel {
    public var points: [ChartDataPoint]
    public var selectedSliceID: ChartDataPoint.ID?
    public var innerRadiusFraction: Double
    public var revealProgress: Double = 0

    public init(points: [ChartDataPoint], innerRadiusFraction: Double = 0) {
        self.points = points
        self.innerRadiusFraction = innerRadiusFraction
    }

    public var slices: [PieSlice] {
        let total = points.map(\.value).reduce(0, +)
        guard total > 0 else { return [] }
        var angle = Angle.degrees(-90)
        return points.map { point in
            let fraction = point.value / total
            let sweep = Angle.degrees(fraction * 360)
            let slice = PieSlice(
                id: point.id,
                point: point,
                startAngle: angle,
                endAngle: angle + sweep,
                fraction: fraction
            )
            angle += sweep
            return slice
        }
    }

    public func select(_ id: ChartDataPoint.ID?) {
        selectedSliceID = selectedSliceID == id ? nil : id
    }

    public func reveal(duration: Double) {
        revealProgress = 0
        withAnimation(.easeOut(duration: duration)) {
            revealProgress = 1
        }
    }
}
