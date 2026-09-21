//
//  ChartAxis.swift
//  KitoCharts
//
//  Created by Wycliff on 1/16/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore

/// Horizontal gridlines with value labels, drawn behind a chart's plot area.
/// `tickCount` is a target, not a guarantee — `niceStep` rounds to a human step.
public struct ValueAxis: View {
    @Environment(\.kitoChartTheme) private var theme
    let domain: ClosedRange<Double>
    let tickCount: Int
    let formatter: (Double) -> String

    public init(
        domain: ClosedRange<Double>,
        tickCount: Int = 4,
        formatter: @escaping (Double) -> String = { String(format: "%.0f", $0) }
    ) {
        self.domain = domain
        self.tickCount = tickCount
        self.formatter = formatter
    }

    public var body: some View {
        GeometryReader { geometry in
            let ticks = niceTicks(domain: domain, targetCount: tickCount)
            ZStack(alignment: .topLeading) {
                ForEach(ticks, id: \.self) { tick in
                    let y = yPosition(for: tick, in: geometry.size.height)
                    if theme.showGridlines {
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                        }
                        .stroke(theme.gridlineColor, lineWidth: 1)
                    }
                    Text(formatter(tick))
                        .font(.caption2)
                        .foregroundStyle(theme.axisLabelColor)
                        .position(x: 20, y: max(y - 8, 8))
                }
            }
        }
    }

    private func yPosition(for value: Double, in height: CGFloat) -> CGFloat {
        let span = domain.upperBound - domain.lowerBound
        guard span != 0 else { return height }
        let t = (value - domain.lowerBound) / span
        return height - CGFloat(t) * height
    }
}

/// Rounds a raw step (e.g. 137.4) to a human-friendly one (100, 50, 25, 20...)
/// so axis labels never read "0, 137.4, 274.8".
func niceTicks(domain: ClosedRange<Double>, targetCount: Int) -> [Double] {
    let span = domain.upperBound - domain.lowerBound
    guard span > 0, targetCount > 0 else { return [domain.lowerBound] }

    let rawStep = span / Double(targetCount)
    let magnitude = pow(10, floor(log10(rawStep)))
    let normalized = rawStep / magnitude
    let niceNormalized: Double = normalized < 1.5 ? 1 : normalized < 3 ? 2 : normalized < 7 ? 5 : 10
    let step = niceNormalized * magnitude

    let start = (domain.lowerBound / step).rounded(.down) * step
    var ticks: [Double] = []
    var value = start
    while value <= domain.upperBound {
        if value >= domain.lowerBound { ticks.append(value) }
        value += step
    }
    return ticks
}
