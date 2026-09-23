//
//  LineChartGeometryTests.swift
//  KitoCharts
//
//  Created by Wycliff on 9/23/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import XCTest
import SwiftUI
@testable import KitoCharts

final class LineChartGeometryTests: XCTestCase {
    private let points = [CGPoint(x: 0, y: 0), CGPoint(x: 10, y: 10), CGPoint(x: 20, y: 5)]

    private func elements(of path: Path) -> [Path.Element] {
        var result: [Path.Element] = []
        path.forEach { result.append($0) }
        return result
    }

    private func data(_ values: [Double]) -> [ChartDataPoint] {
        values.enumerated().map { ChartDataPoint(label: "\($0.offset)", value: $0.element) }
    }

    // MARK: Interpolation

    func testLinearJoinsEveryPointWithAStraightSegment() {
        XCTAssertEqual(elements(of: LineChartGeometry.linePath(through: points, interpolation: .linear)), [
            .move(to: points[0]), .line(to: points[1]), .line(to: points[2]),
        ])
    }

    func testSteppedHoldsEachValueUntilTheNextPoint() {
        XCTAssertEqual(elements(of: LineChartGeometry.linePath(through: points, interpolation: .stepped)), [
            .move(to: points[0]),
            .line(to: CGPoint(x: 10, y: 0)), .line(to: points[1]),
            .line(to: CGPoint(x: 20, y: 10)), .line(to: points[2]),
        ])
    }

    func testCurvesPassThroughEveryPoint() {
        for interpolation in [LineInterpolation.smooth, .catmullRom] {
            let ends = elements(of: LineChartGeometry.linePath(through: points, interpolation: interpolation)).compactMap { element -> CGPoint? in
                switch element {
                case .move(let to), .line(let to): return to
                case .curve(let to, _, _): return to
                default: return nil
                }
            }
            XCTAssertEqual(ends, points, "\(interpolation)")
        }
    }

    func testSmoothCurvesHaveFlatTangentsSoTheyNeverOvershoot() {
        guard case .curve(_, let c1, let c2) = elements(of: LineChartGeometry.linePath(through: points, interpolation: .smooth))[1] else {
            return XCTFail("expected a curve")
        }
        XCTAssertEqual(c1.y, 0)
        XCTAssertEqual(c2.y, 10)
    }

    func testASinglePointIsJustAMove() {
        XCTAssertEqual(elements(of: LineChartGeometry.linePath(through: [points[0]], interpolation: .catmullRom)), [.move(to: points[0])])
        XCTAssertTrue(LineChartGeometry.linePath(through: [], interpolation: .smooth).isEmpty)
    }

    func testTheAreaClosesDownToTheBaseline() {
        let area = elements(of: LineChartGeometry.areaPath(through: points, interpolation: .linear, baselineY: 30))
        XCTAssertEqual(Array(area.suffix(3)), [.line(to: CGPoint(x: 20, y: 30)), .line(to: CGPoint(x: 0, y: 30)), .closeSubpath])
    }

    // MARK: Domain

    func testTheDomainStretchesToShowReferenceLines() {
        let style = LineChartStyle(referenceLines: [LineReferenceLine("Goal", value: 500)])
        XCTAssertEqual(LineChartGeometry.domain(for: data([100, 200]), style: style), 100...500)
    }

    func testIncludesZeroAnchorsTheBaseline() {
        XCTAssertEqual(LineChartGeometry.domain(for: data([100, 200]), style: LineChartStyle(includesZero: true)), 0...200)
        XCTAssertEqual(LineChartGeometry.domain(for: data([100, 200]), style: .default), 100...200)
    }

    func testAnAreaFillKeepsTheDataRangeUnlessAskedForZero() {
        XCTAssertEqual(LineChartGeometry.domain(for: data([170, 180]), style: LineChartStyle(area: .gradient(opacity: 0.3))), 170...180,
                       "a stock chart's fill must not squash the line against the top")
        XCTAssertEqual(LineChartGeometry.domain(for: data([-40, -10]), style: .area), -40...0, "the .area preset anchors at zero")
    }

    func testAFlatSeriesStillGetsAUsableDomain() {
        XCTAssertEqual(LineChartGeometry.domain(for: data([5, 5]), style: .default), 4...6)
    }

    // MARK: Labels

    func testEveryLabelShowsWhenThereIsRoom() {
        XCTAssertEqual(LineChartGeometry.labelIndices(count: 5, width: 400), [0, 1, 2, 3, 4])
    }

    func testCrowdedLabelsAreThinnedButTheLastIsKept() {
        let indices = LineChartGeometry.labelIndices(count: 24, width: 300)
        XCTAssertEqual(indices.first, 0)
        XCTAssertEqual(indices.last, 23)
        let spacing = 300.0 / 23
        for (a, b) in zip(indices, indices.dropFirst()) {
            XCTAssertGreaterThanOrEqual(Double(b - a) * spacing, 34, "labels \(a) and \(b) collide")
        }
    }

    func testLabelEdgeCases() {
        XCTAssertEqual(LineChartGeometry.labelIndices(count: 0, width: 300), [])
        XCTAssertEqual(LineChartGeometry.labelIndices(count: 1, width: 300), [0])
    }

    // MARK: Styles

    func testTheDefaultStyleDrawsWhatTheChartAlwaysDrew() {
        let style = LineChartStyle.default
        XCTAssertNil(style.interpolation, "follows the view model's isSmoothed")
        XCTAssertEqual(style.lineWidth, 2.5)
        XCTAssertEqual(style.points, .none)
        XCTAssertEqual(style.area, .none)
        XCTAssertTrue(style.showsValueAxis)
    }

    func testTheSparklinePresetHasNoAxis() {
        XCTAssertFalse(LineChartStyle.sparkline.showsValueAxis)
        XCTAssertEqual(LineChartStyle.sparkline.points, .lastPoint)
    }
}
