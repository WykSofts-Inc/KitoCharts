//
//  LineChartView.swift
//  KitoCharts
//
//  Created by Wycliff on 1/24/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore

/// Multi-series line chart. Bind a `LineChartViewModel`; this view is a pure
/// function of its state — no logic beyond geometry and hit-testing lives here.
/// Pass a `LineChartStyle` for markers, area fills, step lines, labels, goal lines and more.
public struct LineChartView: View {
    @Environment(\.kitoChartTheme) private var theme
    @Environment(\.layoutDirection) private var layoutDirection
    @Bindable var viewModel: LineChartViewModel
    let style: LineChartStyle
    let showLegend: Bool
    let valueFormatter: (Double) -> String

    public init(
        viewModel: LineChartViewModel,
        style: LineChartStyle = .default,
        showLegend: Bool = true,
        valueFormatter: @escaping (Double) -> String = { String(format: "%.0f", $0) }
    ) {
        self.viewModel = viewModel
        self.style = style
        self.showLegend = showLegend
        self.valueFormatter = valueFormatter
    }

    private var interpolation: LineInterpolation {
        style.interpolation ?? (viewModel.isSmoothed ? .smooth : .linear)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            GeometryReader { geometry in
                let plotRect = plotRect(in: geometry.size)
                let domain = LineChartGeometry.domain(for: viewModel.points, style: style)
                let yScale = LinearScale(domain: domain, range: (plotRect.maxY, plotRect.minY))

                ZStack(alignment: .topLeading) {
                    if style.showsValueAxis {
                        ValueAxis(domain: domain, formatter: valueFormatter)
                            .frame(width: geometry.size.width, height: plotRect.height)
                            .offset(y: plotRect.minY)
                    }

                    ForEach(style.referenceLines) { line in
                        referenceLine(line, plotRect: plotRect, yScale: yScale)
                    }

                    ZStack(alignment: .topLeading) {
                        ForEach(Array(viewModel.series.enumerated()), id: \.offset) { index, series in
                            seriesLayer(series.points, colorIndex: index, plotRect: plotRect, yScale: yScale, domain: domain, height: geometry.size.height)
                        }
                    }
                    .mask(alignment: .leading) {
                        Rectangle().frame(width: geometry.size.width * viewModel.revealProgress)
                    }

                    if style.showsLabels {
                        xAxisLabels(plotRect: plotRect)
                    }

                    if let selected = viewModel.selectedPoint {
                        selectionIndicator(for: selected, plotRect: plotRect, yScale: yScale)
                    }
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { drag in
                            guard let first = viewModel.series.first else { return }
                            // The plot is drawn mirrored in right-to-left layouts, but drag locations
                            // are physical: flip x so the nearest point is found in plot coordinates.
                            var location = drag.location
                            if layoutDirection == .rightToLeft { location.x = geometry.size.width - location.x }
                            viewModel.select(pointNear: location, in: first.points, xScale: xScale(count: first.points.count, plotRect: plotRect))
                        }
                        .onEnded { _ in viewModel.clearSelection() }
                )
            }
            // 200 when the caller says nothing; a caller's own .frame(height:) wins, down to
            // sparkline size.
            .frame(minHeight: 44, idealHeight: 200)
            .onAppear {
                if style.animatesIn {
                    viewModel.reveal(duration: theme.animationDuration)
                } else {
                    viewModel.revealProgress = 1
                }
            }

            if showLegend, viewModel.series.count > 1 {
                ChartLegend(categories: viewModel.points.categories)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilitySummary)
    }

    // MARK: Layout

    private var markerPadding: CGFloat {
        switch style.points {
        case .none: return style.lineWidth
        case .filled, .hollow: return style.pointSize * 0.6
        case .halo, .lastPoint: return style.pointSize * 1.3
        }
    }

    private func plotRect(in size: CGSize) -> CGRect {
        let left: CGFloat = style.showsValueAxis ? 40 : (style.showsLabels ? 16 : markerPadding)
        let right: CGFloat = max(style.showsLabels ? 16 : 8, markerPadding)
        let top: CGFloat = style.showsValues ? 20 : max(markerPadding, style.referenceLines.isEmpty ? 2 : 14)
        let bottom: CGFloat = style.showsLabels ? 24 : max(markerPadding, 2)
        return CGRect(x: left, y: top, width: max(size.width - left - right, 1), height: max(size.height - top - bottom, 1))
    }

    private func xScale(count: Int, plotRect: CGRect) -> LinearScale {
        LinearScale(domain: 0...Double(max(count - 1, 1)), range: (plotRect.minX, plotRect.maxX))
    }

    private func positions(_ points: [ChartDataPoint], plotRect: CGRect, yScale: LinearScale) -> [CGPoint] {
        let xScale = xScale(count: points.count, plotRect: plotRect)
        return points.enumerated().map { CGPoint(x: xScale.scale(Double($0.offset)), y: yScale.scale($0.element.value)) }
    }

    // MARK: Series

    @ViewBuilder
    private func seriesLayer(_ points: [ChartDataPoint], colorIndex: Int, plotRect: CGRect, yScale: LinearScale, domain: ClosedRange<Double>, height: CGFloat) -> some View {
        let color = theme.color(forCategoryIndex: colorIndex)
        let cgPoints = positions(points, plotRect: plotRect, yScale: yScale)
        let baselineY = yScale.scale(min(max(0, domain.lowerBound), domain.upperBound))
        let topY = cgPoints.map(\.y).min() ?? plotRect.minY

        areaFill(through: cgPoints, color: color, baselineY: baselineY, topY: topY, height: height)

        LineChartGeometry.linePath(through: cgPoints, interpolation: interpolation)
            .stroke(lineStyle(color), style: StrokeStyle(lineWidth: style.lineWidth, lineCap: .round, lineJoin: .round, dash: style.dash))
            .shadow(color: style.glows ? color.opacity(0.75) : .clear, radius: style.glows ? 7 : 0)

        ForEach(Array(cgPoints.enumerated()), id: \.offset) { index, position in
            if style.points != .lastPoint || index == cgPoints.count - 1 {
                LinePointMarker(style: style.points, color: color, size: style.pointSize)
                    .position(position)
            }
            if style.showsValues {
                Text(valueFormatter(points[index].value))
                    .font(.caption2.weight(.semibold).monospacedDigit())
                    .foregroundStyle(theme.axisLabelColor)
                    .fixedSize()
                    .position(x: position.x, y: position.y - max(style.pointSize / 2, style.lineWidth) - 9)
            }
        }
    }

    @ViewBuilder
    private func areaFill(through points: [CGPoint], color: Color, baselineY: CGFloat, topY: CGFloat, height: CGFloat) -> some View {
        let path = LineChartGeometry.areaPath(through: points, interpolation: interpolation, baselineY: baselineY)
        switch style.area {
        case .none:
            EmptyView()
        case .solid(let opacity):
            path.fill(color.opacity(opacity))
        case .gradient(let opacity):
            // Fade from the highest point to the baseline, not across the whole view.
            let safeHeight = max(height, 1)
            path.fill(LinearGradient(
                colors: [color.opacity(opacity), color.opacity(0)],
                startPoint: UnitPoint(x: 0.5, y: topY / safeHeight),
                endPoint: UnitPoint(x: 0.5, y: baselineY / safeHeight)
            ))
        }
    }

    private func lineStyle(_ color: Color) -> AnyShapeStyle {
        if let gradient = style.strokeGradient, !gradient.isEmpty {
            return AnyShapeStyle(LinearGradient(colors: gradient, startPoint: .leading, endPoint: .trailing))
        }
        return AnyShapeStyle(color)
    }

    // MARK: Guides

    @ViewBuilder
    private func referenceLine(_ line: LineReferenceLine, plotRect: CGRect, yScale: LinearScale) -> some View {
        let y = yScale.scale(line.value)
        let color = line.color ?? theme.axisColor

        Path { path in
            path.move(to: CGPoint(x: plotRect.minX, y: y))
            path.addLine(to: CGPoint(x: plotRect.maxX, y: y))
        }
        .stroke(color, style: StrokeStyle(lineWidth: 1.2, dash: line.isDashed ? [5, 4] : []))

        Text(line.label)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 1)
            .background(.background.opacity(0.85), in: Capsule())
            .fixedSize()
            .frame(width: plotRect.width, alignment: .trailing)
            .position(x: plotRect.midX, y: y - 9)
    }

    @ViewBuilder
    private func xAxisLabels(plotRect: CGRect) -> some View {
        if let longest = viewModel.series.max(by: { $0.points.count < $1.points.count }) {
            let xScale = xScale(count: longest.points.count, plotRect: plotRect)
            ForEach(LineChartGeometry.labelIndices(count: longest.points.count, width: plotRect.width), id: \.self) { index in
                Text(longest.points[index].label)
                    .font(.caption2)
                    .foregroundStyle(theme.axisLabelColor)
                    .fixedSize()
                    .position(x: xScale.scale(Double(index)), y: plotRect.maxY + 14)
            }
        }
    }

    // MARK: Selection

    @ViewBuilder
    private func selectionIndicator(for point: ChartDataPoint, plotRect: CGRect, yScale: LinearScale) -> some View {
        if let first = viewModel.series.first, let index = first.points.firstIndex(where: { $0.id == point.id }) {
            let x = xScale(count: first.points.count, plotRect: plotRect).scale(Double(index))
            let y = yScale.scale(point.value)

            Path { path in
                path.move(to: CGPoint(x: x, y: plotRect.minY))
                path.addLine(to: CGPoint(x: x, y: plotRect.maxY))
            }
            .stroke(theme.axisColor, style: StrokeStyle(lineWidth: 1, dash: [3, 3]))

            Circle()
                .fill(theme.color(forCategoryIndex: 0))
                .frame(width: 10, height: 10)
                .overlay(Circle().stroke(.background, lineWidth: 2))
                .position(x: x, y: y)

            Text("\(point.label): \(valueFormatter(point.value))")
                .font(.caption.bold())
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.thinMaterial, in: Capsule())
                .fixedSize()
                .position(x: min(max(x, plotRect.minX + 56), plotRect.maxX - 56), y: max(y - 24, 12))
        }
    }

    private var accessibilitySummary: String {
        let series = viewModel.series
        guard let first = series.first, let start = first.points.first, let end = first.points.last else {
            return "Line chart, no data"
        }
        let seriesText = series.count > 1 ? "\(series.count) series, " : ""
        return "Line chart, \(seriesText)\(first.points.count) points, from \(start.label) \(valueFormatter(start.value)) to \(end.label) \(valueFormatter(end.value))"
    }
}

/// One data-point marker. `.lastPoint` pulses unless Reduce Motion is on.
struct LinePointMarker: View {
    let style: LinePointStyle
    let color: Color
    let size: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pulsing = false

    var body: some View {
        switch style {
        case .none:
            EmptyView()
        case .filled:
            Circle().fill(color).frame(width: size, height: size)
        case .hollow:
            Circle()
                .fill(.background)
                .overlay(Circle().strokeBorder(color, lineWidth: max(size * 0.28, 1.5)))
                .frame(width: size, height: size)
        case .halo:
            Circle()
                .fill(color)
                .frame(width: size, height: size)
                .background(Circle().fill(color.opacity(0.25)).frame(width: size * 2.2, height: size * 2.2))
        case .lastPoint:
            ZStack {
                Circle()
                    .fill(color.opacity(0.35))
                    .frame(width: size * 2.6, height: size * 2.6)
                    .scaleEffect(pulsing ? 1 : 0.4)
                    .opacity(pulsing ? 0 : 1)
                Circle().fill(color).frame(width: size, height: size)
            }
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.easeOut(duration: 1.4).repeatForever(autoreverses: false)) { pulsing = true }
            }
        }
    }
}
