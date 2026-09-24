//
//  PieChartView.swift
//  KitoCharts
//
//  Created by Wycliff on 1/25/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore

/// Pie or donut chart — `viewModel.innerRadiusFraction` decides which.
/// Tapping a slice selects it and pops it outward slightly.
public struct PieChartView: View {
    @Environment(\.kitoChartTheme) private var theme
    @Bindable var viewModel: PieChartViewModel
    let showLegend: Bool
    let centerContent: AnyView?

    public init(viewModel: PieChartViewModel, showLegend: Bool = true) {
        self.viewModel = viewModel
        self.showLegend = showLegend
        self.centerContent = nil
    }

    /// A pie or donut with `center` drawn in the middle while no slice is selected, e.g. the
    /// total for a donut (`innerRadiusFraction` > 0). Selecting a slice swaps it for that
    /// slice's label and share.
    ///
    /// ```swift
    /// PieChartView(viewModel: spending) {
    ///     VStack { Text("Total").font(.caption); Text("$1,240").font(.title3.bold()) }
    /// }
    /// ```
    public init<Center: View>(viewModel: PieChartViewModel, showLegend: Bool = true, @ViewBuilder center: () -> Center) {
        self.viewModel = viewModel
        self.showLegend = showLegend
        self.centerContent = AnyView(center())
    }

    /// One colour per point, used by the slice, the legend and the selection alike: the
    /// point's own `color`, or the theme's palette by position.
    private func color(at index: Int) -> Color {
        viewModel.points.indices.contains(index)
            ? viewModel.points[index].color ?? theme.color(forCategoryIndex: index)
            : theme.color(forCategoryIndex: index)
    }

    public var body: some View {
        VStack(spacing: 12) {
            GeometryReader { geometry in
                let radius = min(geometry.size.width, geometry.size.height) / 2
                let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)

                ZStack {
                    ForEach(Array(viewModel.slices.enumerated()), id: \.element.id) { index, slice in
                        sliceShape(slice, center: center, radius: radius)
                            .fill(color(at: index))
                            .scaleEffect(viewModel.selectedSliceID == slice.id ? 1.05 : 1.0)
                            .opacity(viewModel.revealProgress)
                            .animation(.easeOut(duration: theme.animationDuration), value: viewModel.revealProgress)
                            .onTapGesture { viewModel.select(slice.id) }
                    }

                    if let selected = viewModel.slices.first(where: { $0.id == viewModel.selectedSliceID }) {
                        VStack(spacing: 2) {
                            Text(selected.point.label).font(.caption.bold())
                            Text(selected.fraction, format: .percent.precision(.fractionLength(0))).font(.caption2).foregroundStyle(.secondary)
                        }
                    } else if let centerContent {
                        centerContent
                            .frame(maxWidth: radius * 2 * max(viewModel.innerRadiusFraction, 0.5) * 0.9)
                            .allowsHitTesting(false)
                    }
                }
            }
            .aspectRatio(1, contentMode: .fit)

            if showLegend {
                ChartLegend(
                    categories: viewModel.points.map(\.label),
                    colors: viewModel.points.indices.map { color(at: $0) },
                    highlighted: viewModel.points.firstIndex { $0.id == viewModel.selectedSliceID }
                )
            }
        }
        .onAppear { viewModel.reveal(duration: theme.animationDuration) }
    }

    private func sliceShape(_ slice: PieSlice, center: CGPoint, radius: CGFloat) -> Path {
        Path { path in
            let innerRadius = radius * viewModel.innerRadiusFraction
            path.move(to: point(on: center, radius: innerRadius, angle: slice.startAngle))
            path.addArc(center: center, radius: radius, startAngle: slice.startAngle, endAngle: slice.endAngle, clockwise: false)
            path.addLine(to: point(on: center, radius: innerRadius, angle: slice.endAngle))
            if innerRadius > 0 {
                path.addArc(center: center, radius: innerRadius, startAngle: slice.endAngle, endAngle: slice.startAngle, clockwise: true)
            }
            path.closeSubpath()
        }
    }

    private func point(on center: CGPoint, radius: CGFloat, angle: Angle) -> CGPoint {
        CGPoint(x: center.x + radius * cos(angle.radians), y: center.y + radius * sin(angle.radians))
    }
}
