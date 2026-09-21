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
public struct LinearScale {
    public let domain: ClosedRange<Double>
    public let range: ClosedRange<CGFloat>

    public init(domain: ClosedRange<Double>, range: ClosedRange<CGFloat>) {
        self.domain = domain
        self.range = range
    }

    public func scale(_ value: Double) -> CGFloat {
        let domainSpan = domain.upperBound - domain.lowerBound
        guard domainSpan != 0 else { return range.lowerBound }
        let t = (value - domain.lowerBound) / domainSpan
        return range.lowerBound + CGFloat(t) * (range.upperBound - range.lowerBound)
    }

    /// Convenience for a value axis that should always include zero
    /// (bars/areas look wrong if the baseline floats).
    public static func valueScale(for points: [ChartDataPoint], range: ClosedRange<CGFloat>) -> LinearScale {
        let values = points.map(\.value)
        let rawMin = min(values.min() ?? 0, 0)
        let rawMax = max(values.max() ?? 1, rawMin + 1)
        return LinearScale(domain: rawMin...rawMax, range: range)
    }
}
