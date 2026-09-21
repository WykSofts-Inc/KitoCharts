//
//  LinearScale.swift
//  KitoCharts
//
//  Created by Wycliff on 1/15/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import CoreGraphics

/// Maps a value range onto a pixel range. Every chart uses this instead of
/// hand-rolled arithmetic, so padding/clamping behavior is identical everywhere.
///
/// `range` is a plain `(CGFloat, CGFloat)` tuple, deliberately **not**
/// `ClosedRange<CGFloat>`. A `ClosedRange` traps at construction if its
/// lower bound exceeds its upper bound — and a Y-axis needs exactly that
/// ordering: screen-space Y increases downward while chart values increase
/// upward, so `domain.lowerBound` legitimately maps to the *larger* on-screen
/// Y coordinate. `LineChartView` crashed on every real render before this
/// fix, because `ClosedRange(plotRect.maxY...plotRect.minY)` traps whenever
/// `maxY > minY` — which is every rect with positive height. Caught only by
/// actually running the view, not by unit-testing the math in isolation.
public struct LinearScale {
    public let domain: ClosedRange<Double>
    private let rangeStart: CGFloat
    private let rangeEnd: CGFloat

    /// Maps `domain.lowerBound` → `range.0` and `domain.upperBound` → `range.1`.
    /// `range.0` may be greater than `range.1` — that's the whole point.
    public init(domain: ClosedRange<Double>, range: (CGFloat, CGFloat)) {
        self.domain = domain
        self.rangeStart = range.0
        self.rangeEnd = range.1
    }

    public func scale(_ value: Double) -> CGFloat {
        let domainSpan = domain.upperBound - domain.lowerBound
        guard domainSpan != 0 else { return rangeStart }
        let t = (value - domain.lowerBound) / domainSpan
        return rangeStart + CGFloat(t) * (rangeEnd - rangeStart)
    }

    /// Convenience for a value axis that should always include zero
    /// (bars/areas look wrong if the baseline floats).
    public static func valueScale(for points: [ChartDataPoint], range: (CGFloat, CGFloat)) -> LinearScale {
        let values = points.map(\.value)
        let rawMin = min(values.min() ?? 0, 0)
        let rawMax = max(values.max() ?? 1, rawMin + 1)
        return LinearScale(domain: rawMin...rawMax, range: range)
    }
}
