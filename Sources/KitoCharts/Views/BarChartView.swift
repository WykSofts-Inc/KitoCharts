//
//  BarChartView.swift
//  KitoCharts
//
//  Created by Wycliff on 1/22/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore

/// Vertical or horizontal bar chart, single or grouped-by-category. Bind a
/// `BarChartViewModel`; this view only lays out and animates its bars.
public struct BarChartView: View {
    @Environment(\.kitoChartTheme) private var theme
    @Bindable var viewModel: BarChartViewModel
    let cornerRadius: CGFloat
    let valueFormatter: (Double) -> String

    public init(
        viewModel: BarChartViewModel,
        cornerRadius: CGFloat = 6,
        valueFormatter: @escaping (Double) -> String = { String(format: "%.0f", $0) }
    ) {
        self.viewModel = viewModel
        self.cornerRadius = cornerRadius
        self.valueFormatter = valueFormatter
    }

    public var body: some View {
        GeometryReader { geometry in
            let plotWidth = geometry.size.width - 40
            let domain = viewModel.points.valueRange
            let groups = viewModel.groupedByLabel

            HStack(alignment: .bottom, spacing: plotWidth / CGFloat(max(groups.count, 1)) * 0.3) {
                ForEach(Array(groups.enumerated()), id: \.offset) { _, group in
                    HStack(alignment: .bottom, spacing: 2) {
                        ForEach(Array(group.points.enumerated()), id: \.element.id) { index, point in
                            bar(for: point, categoryIndex: index, domain: domain, maxHeight: geometry.size.height - 24)
                        }
                    }
                    .overlay(alignment: .bottom) {
                        Text(group.label)
                            .font(.caption2)
                            .foregroundStyle(theme.axisLabelColor)
                            .fixedSize()
                            .offset(y: 18)
                    }
                }
            }
            .frame(width: plotWidth, height: geometry.size.height - 24, alignment: .bottom)
            .offset(x: 40)
            .overlay(alignment: .topLeading) {
                ValueAxis(domain: domain, formatter: valueFormatter)
                    .frame(width: geometry.size.width, height: geometry.size.height - 24)
                    .allowsHitTesting(false)
            }
        }
        .frame(minHeight: 220)
        .onAppear { viewModel.grow(duration: theme.animationDuration) }
    }

    @ViewBuilder
    private func bar(for point: ChartDataPoint, categoryIndex: Int, domain: ClosedRange<Double>, maxHeight: CGFloat) -> some View {
        let scale = LinearScale(domain: domain, range: (0, maxHeight))
        let height = max(scale.scale(point.value), 2) * viewModel.growProgress
        let isHighlighted = viewModel.highlightedPointID == point.id

        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(point.color ?? theme.color(forCategoryIndex: categoryIndex))
            .opacity(viewModel.highlightedPointID == nil || isHighlighted ? 1 : 0.35)
            .frame(width: 28, height: height)
            .onTapGesture {
                viewModel.highlight(isHighlighted ? nil : point.id)
            }
    }
}
