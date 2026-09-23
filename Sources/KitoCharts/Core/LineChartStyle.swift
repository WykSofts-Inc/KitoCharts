//
//  LineChartStyle.swift
//  KitoCharts
//
//  Created by Wycliff on 9/23/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI

/// How `LineChartView` joins consecutive points.
public enum LineInterpolation: Equatable, Sendable {
    /// Straight segments.
    case linear
    /// Curves with horizontal tangents at each point: smooth, and never overshoots a peak.
    case smooth
    /// Catmull–Rom: the most natural-looking curve through every point; can overshoot slightly
    /// on sharp turns.
    case catmullRom
    /// Holds each value until the next point, like a price tier or a state that changes.
    case stepped
}

/// The marker drawn on each data point.
public enum LinePointStyle: Equatable, Sendable {
    case none
    /// A solid dot in the series colour.
    case filled
    /// A ring in the series colour with the background showing through.
    case hollow
    /// A solid dot with a soft halo.
    case halo
    /// Only the latest point, with a pulsing halo: the "live value" look.
    case lastPoint
}

/// What `LineChartView` draws under each line: down to zero when the axis includes it, otherwise
/// to the bottom of the plot, so a price moving between 170 and 180 still fills its chart.
public enum LineAreaFill: Equatable, Sendable {
    case none
    /// A flat fill in the series colour.
    case solid(opacity: Double)
    /// The series colour fading to clear toward the baseline.
    case gradient(opacity: Double)
}

/// A horizontal guide at a fixed value: a goal, a limit, an average.
public struct LineReferenceLine: Equatable, Sendable, Identifiable {
    public var value: Double
    public var label: String
    /// nil uses the theme's axis colour.
    public var color: Color?
    public var isDashed: Bool

    public var id: String { "\(label)|\(value)" }

    public init(_ label: String, value: Double, color: Color? = nil, isDashed: Bool = true) {
        self.label = label
        self.value = value
        self.color = color
        self.isDashed = isDashed
    }
}

/// Everything about how a line chart looks, independent of its data. Pass one to
/// `LineChartView(viewModel:style:)`; the default draws what `LineChartView` always drew.
public struct LineChartStyle: Equatable, Sendable {
    /// nil follows the view model's `isSmoothed`.
    public var interpolation: LineInterpolation?
    public var lineWidth: CGFloat
    /// Dash pattern for the line; empty is solid.
    public var dash: [CGFloat]
    public var points: LinePointStyle
    public var pointSize: CGFloat
    public var area: LineAreaFill
    /// Colours the line with a left-to-right gradient instead of the series colour.
    public var strokeGradient: [Color]?
    /// A soft glow in the line's colour, for dark and neon designs.
    public var glows: Bool
    /// The value labels and gridlines on the left.
    public var showsValueAxis: Bool
    /// Each point's label along the bottom, thinned out when they would collide.
    public var showsLabels: Bool
    /// Each point's value above it.
    public var showsValues: Bool
    /// Stretches the value axis to include zero, so the baseline doesn't float.
    public var includesZero: Bool
    public var referenceLines: [LineReferenceLine]
    /// Wipes the chart in from the left when it appears.
    public var animatesIn: Bool

    public init(
        interpolation: LineInterpolation? = nil,
        lineWidth: CGFloat = 2.5,
        dash: [CGFloat] = [],
        points: LinePointStyle = .none,
        pointSize: CGFloat = 7,
        area: LineAreaFill = .none,
        strokeGradient: [Color]? = nil,
        glows: Bool = false,
        showsValueAxis: Bool = true,
        showsLabels: Bool = false,
        showsValues: Bool = false,
        includesZero: Bool = false,
        referenceLines: [LineReferenceLine] = [],
        animatesIn: Bool = true
    ) {
        self.interpolation = interpolation
        self.lineWidth = lineWidth
        self.dash = dash
        self.points = points
        self.pointSize = pointSize
        self.area = area
        self.strokeGradient = strokeGradient
        self.glows = glows
        self.showsValueAxis = showsValueAxis
        self.showsLabels = showsLabels
        self.showsValues = showsValues
        self.includesZero = includesZero
        self.referenceLines = referenceLines
        self.animatesIn = animatesIn
    }

    public static let `default` = LineChartStyle()

    /// A compact, axis-free trend line with a soft fill, for table rows and stat tiles.
    public static let sparkline = LineChartStyle(
        interpolation: .smooth, lineWidth: 2, points: .lastPoint, pointSize: 6,
        area: .gradient(opacity: 0.3), showsValueAxis: false
    )

    /// A filled area chart.
    public static let area = LineChartStyle(interpolation: .smooth, area: .gradient(opacity: 0.35), includesZero: true)
}
