//
//  ChartDataPoint.swift
//  KitoCharts
//
//  Created by Wycliff on 1/13/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI

/// One plotted value. `category` groups points into series (multi-line charts,
/// stacked bars); `color` overrides the theme's categorical palette for this
/// point specifically (e.g. highlighting an outlier) and is nil in the common case.
public struct ChartDataPoint: Identifiable, Equatable, Sendable {
    public let id: UUID
    public var label: String
    public var value: Double
    public var category: String
    public var color: Color?

    public init(
        id: UUID = UUID(),
        label: String,
        value: Double,
        category: String = "default",
        color: Color? = nil
    ) {
        self.id = id
        self.label = label
        self.value = value
        self.category = category
        self.color = color
    }
}

public extension Array where Element == ChartDataPoint {
    var categories: [String] {
        var seen = Set<String>()
        var ordered: [String] = []
        for point in self where seen.insert(point.category).inserted {
            ordered.append(point.category)
        }
        return ordered
    }

    var valueRange: ClosedRange<Double> {
        guard let min = self.map(\.value).min(), let max = self.map(\.value).max() else {
            return 0...1
        }
        return min == max ? (min - 1)...(max + 1) : min...max
    }
}
