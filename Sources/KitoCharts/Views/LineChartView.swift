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
public struct LineChartView: View {
    @Environment(\.kitoChartTheme) private var theme
    @Bindable var viewModel: LineChartViewModel
    let showLegend: Bool
    let valueFormatter: (Double) -> String

    public init(
        viewModel: LineChartViewModel,
        showLegend: Bool = true,
        valueFormatter: @escaping (Double) -> String = { String(format: "%.0f", $0) }
    ) {
        self.viewModel = viewModel
        self.showLegend = showLegend
        self.valueFormatter = valueFormatter
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            GeometryReader { geometry in
                let plotRect = CGRect(x: 40, y: 0, width: geometry.size.width - 48, height: geometry.size.height - 24)
                let domain = viewModel.points.valueRange
                let yScale = LinearScale(domain: domain, range: plotRect.maxY...plotRect.minY)

                ZStack(alignment: .topLeading) {
                    ValueAxis(domain: domain, formatter: valueFormatter)
                        .frame(width: geometry.size.width, height: plotRect.height)

                    ForEach(Array(viewModel.series.enumerated()), id: \.offset) { index, series in
                        let xScale = LinearScale(
                            domain: 0...Double(max(series.points.count - 1, 1)),
                            range: plotRect.minX...plotRect.maxX
                        )
                        seriesPath(series.points, xScale: xScale, yScale: yScale)
                            .trim(from: 0, to: viewModel.revealProgress)
                            .stroke(
                                theme.color(forCategoryIndex: index),
                                style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
                            )
                    }

                    if let selected = viewModel.selectedPoint {
                        selectionCallout(for: selected, plotRect: plotRect, yScale: yScale)
                    }
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { drag in
                            guard let first = viewModel.series.first else { return }
                            let xScale = LinearScale(
                                domain: 0...Double(max(first.points.count - 1, 1)),
                                range: plotRect.minX...plotRect.maxX
                            )
                            viewModel.select(pointNear: drag.location, in: first.points, xScale: xScale)
                        }
                        .onEnded { _ in viewModel.clearSelection() }
                )
            }
            .frame(minHeight: 200)
            .onAppear { viewModel.reveal(duration: theme.animationDuration) }

            if showLegend, viewModel.series.count > 1 {
                ChartLegend(categories: viewModel.points.categories)
            }
        }
    }

    private func seriesPath(_ points: [ChartDataPoint], xScale: LinearScale, yScale: LinearScale) -> Path {
        Path { path in
            for (index, point) in points.enumerated() {
                let cgPoint = CGPoint(x: xScale.scale(Double(index)), y: yScale.scale(point.value))
                if index == 0 {
                    path.move(to: cgPoint)
                } else if viewModel.isSmoothed {
                    let previous = CGPoint(x: xScale.scale(Double(index - 1)), y: yScale.scale(points[index - 1].value))
                    let midX = (previous.x + cgPoint.x) / 2
                    path.addCurve(
                        to: cgPoint,
                        control1: CGPoint(x: midX, y: previous.y),
                        control2: CGPoint(x: midX, y: cgPoint.y)
                    )
                } else {
                    path.addLine(to: cgPoint)
                }
            }
        }
    }

    @ViewBuilder
    private func selectionCallout(for point: ChartDataPoint, plotRect: CGRect, yScale: LinearScale) -> some View {
        Text("\(point.label): \(valueFormatter(point.value))")
            .font(.caption.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.thinMaterial, in: Capsule())
            .position(x: plotRect.midX, y: max(yScale.scale(point.value) - 16, 12))
    }
}
