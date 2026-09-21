//
//  KitoChartsTests.swift
//  KitoCharts
//
//  Created by Wycliff on 1/26/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import XCTest
@testable import KitoCharts

final class KitoChartsTests: XCTestCase {
    private func samplePoints() -> [ChartDataPoint] {
        [
            ChartDataPoint(label: "Mon", value: 10),
            ChartDataPoint(label: "Tue", value: 25),
            ChartDataPoint(label: "Wed", value: 8),
            ChartDataPoint(label: "Thu", value: 30),
        ]
    }

    func testLinearScaleMapsDomainToRange() {
        let scale = LinearScale(domain: 0...100, range: (0, 200))
        XCTAssertEqual(scale.scale(0), 0)
        XCTAssertEqual(scale.scale(100), 200)
        XCTAssertEqual(scale.scale(50), 100)
    }

    func testLinearScaleHandlesZeroSpanDomain() {
        let scale = LinearScale(domain: 5...5, range: (0, 100))
        XCTAssertEqual(scale.scale(5), 0)
    }

    func testLinearScaleHandlesReversedRangeWithoutCrashing() {
        // The exact shape every chart's Y-axis needs: screen Y increases
        // downward while values increase upward, so the low end of the
        // domain must map to the LARGER on-screen coordinate. A
        // ClosedRange<CGFloat>-based range would trap constructing this;
        // the tuple-based range must not.
        let scale = LinearScale(domain: 0...100, range: (200, 0))
        XCTAssertEqual(scale.scale(0), 200)
        XCTAssertEqual(scale.scale(100), 0)
        XCTAssertEqual(scale.scale(50), 100)
    }

    func testLinearScaleHandlesNegativeSpanRangeWithoutCrashing() {
        // A degenerate/very small view (geometry.size.height < the chart's
        // fixed insets) can produce a negative plot height. This must
        // render oddly, never crash.
        let scale = LinearScale(domain: 0...10, range: (0, -5))
        XCTAssertEqual(scale.scale(10), -5)
    }

    func testValueRangeIncludesAllPoints() {
        let range = samplePoints().valueRange
        XCTAssertEqual(range.lowerBound, 8)
        XCTAssertEqual(range.upperBound, 30)
    }

    func testPieChartSlicesSumTo360Degrees() {
        let viewModel = PieChartViewModel(points: samplePoints())
        let totalDegrees = viewModel.slices.reduce(0.0) { $0 + ($1.endAngle.degrees - $1.startAngle.degrees) }
        XCTAssertEqual(totalDegrees, 360, accuracy: 0.001)
    }

    func testPieChartSelectionToggles() {
        let points = samplePoints()
        let viewModel = PieChartViewModel(points: points)
        let firstID = points[0].id
        viewModel.select(firstID)
        XCTAssertEqual(viewModel.selectedSliceID, firstID)
        viewModel.select(firstID)
        XCTAssertNil(viewModel.selectedSliceID, "selecting the same slice twice should deselect")
    }

    func testBarChartGroupsByLabel() {
        let viewModel = BarChartViewModel(points: samplePoints())
        XCTAssertEqual(viewModel.groupedByLabel.count, 4)
    }

    func testNiceTicksStaysWithinDomain() {
        let ticks = niceTicks(domain: 0...97, targetCount: 4)
        XCTAssertTrue(ticks.allSatisfy { $0 >= 0 && $0 <= 97 })
        XCTAssertFalse(ticks.isEmpty)
    }

    func testChartThemeColorWrapsAroundPalette() {
        let theme = KitoChartTheme.default
        let paletteCount = theme.categoricalPalette.count
        XCTAssertEqual(theme.color(forCategoryIndex: 0), theme.color(forCategoryIndex: paletteCount))
    }
}
