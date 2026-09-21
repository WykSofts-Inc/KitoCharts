//
//  ChartLegend.swift
//  KitoCharts
//
//  Created by Wycliff on 1/17/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore

/// A wrapping legend row. Any chart with more than one category hands this
/// its categories and a color lookup — no chart type re-implements legend layout.
public struct ChartLegend: View {
    @Environment(\.kitoChartTheme) private var theme
    let categories: [String]

    public init(categories: [String]) {
        self.categories = categories
    }

    public var body: some View {
        FlowLayout(spacing: 12) {
            ForEach(Array(categories.enumerated()), id: \.offset) { index, category in
                HStack(spacing: 6) {
                    Circle()
                        .fill(theme.color(forCategoryIndex: index))
                        .frame(width: 8, height: 8)
                    Text(category)
                        .font(.caption)
                        .foregroundStyle(theme.axisLabelColor)
                }
            }
        }
    }
}

/// Minimal wrapping HStack. SwiftUI's `Layout` protocol keeps this in ~30
/// lines instead of a UIKit flow-layout dependency.
struct FlowLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > width, currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        return CGSize(width: width, height: currentY + lineHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX: CGFloat = bounds.minX
        var currentY: CGFloat = bounds.minY
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > bounds.maxX, currentX > bounds.minX {
                currentX = bounds.minX
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            subview.place(at: CGPoint(x: currentX, y: currentY), proposal: .unspecified)
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}
