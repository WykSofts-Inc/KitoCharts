//
//  Chart3DPieViewModel.swift
//  KitoCharts
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import Observation
import KitoCore
#if canImport(SceneKit)
import SceneKit
import UIKit

/// A real 3D pie/donut — each slice is an extruded wedge (`SCNShape` built
/// from a 2D pie-slice `UIBezierPath`, given depth), not a texture-mapped
/// flat disc. Bind this like `Chart3DViewModel`; call `rebuild()` after
/// mutating `points` or `innerRadiusFraction`.
@Observable
public final class Chart3DPieViewModel: KitoViewModel {
    public var points: [ChartDataPoint]
    public var theme: KitoChartTheme
    /// 0 = solid pie, closer to 1 = a thin ring — same idea as
    /// `PieChartViewModel.innerRadiusFraction`, just extruded in 3D.
    public var innerRadiusFraction: Double
    public var extrusionDepth: Double
    public private(set) var scene: SCNScene

    public init(
        points: [ChartDataPoint],
        innerRadiusFraction: Double = 0,
        extrusionDepth: Double = 0.6,
        theme: KitoChartTheme = .default
    ) {
        self.points = points
        self.innerRadiusFraction = innerRadiusFraction
        self.extrusionDepth = extrusionDepth
        self.theme = theme
        self.scene = Self.buildScene(points: points, innerRadiusFraction: innerRadiusFraction, extrusionDepth: extrusionDepth, theme: theme)
    }

    public func rebuild() {
        scene = Self.buildScene(points: points, innerRadiusFraction: innerRadiusFraction, extrusionDepth: extrusionDepth, theme: theme)
    }

    private static func buildScene(
        points: [ChartDataPoint],
        innerRadiusFraction: Double,
        extrusionDepth: Double,
        theme: KitoChartTheme
    ) -> SCNScene {
        let scene = SCNScene()
        let total = points.map(\.value).reduce(0, +)
        guard total > 0 else { return scene }

        let outerRadius: CGFloat = 2.2
        let innerRadius = outerRadius * CGFloat(min(max(innerRadiusFraction, 0), 0.92))
        var startAngle: CGFloat = -.pi / 2

        for (index, point) in points.enumerated() {
            let fraction = point.value / total
            let sweep = CGFloat(fraction) * 2 * .pi
            let endAngle = startAngle + sweep

            let path = wedgePath(outerRadius: outerRadius, innerRadius: innerRadius, startAngle: startAngle, endAngle: endAngle)
            let shape = SCNShape(path: path, extrusionDepth: extrusionDepth)
            let color = point.color ?? theme.color(forCategoryIndex: index)
            shape.firstMaterial?.diffuse.contents = UIColor(color)
            shape.firstMaterial?.specular.contents = UIColor.white
            shape.firstMaterial?.isDoubleSided = true

            let node = SCNNode(geometry: shape)
            // SCNShape extrudes flat along its local Z axis — rotate the
            // whole wedge to lie flat, like a pie sitting on a table, viewed
            // from above by the camera below.
            node.eulerAngles.x = -.pi / 2
            node.position = SCNVector3(0, Float(extrusionDepth) / 2, 0)
            scene.rootNode.addChildNode(node)

            startAngle = endAngle
        }

        let camera = SCNCamera()
        camera.fieldOfView = 40
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 6, 4.5)
        cameraNode.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(cameraNode)

        let light = SCNLight()
        light.type = .omni
        light.intensity = 1400
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(0, 8, 6)
        scene.rootNode.addChildNode(lightNode)

        let ambient = SCNLight()
        ambient.type = .ambient
        ambient.intensity = 450
        let ambientNode = SCNNode()
        ambientNode.light = ambient
        scene.rootNode.addChildNode(ambientNode)

        return scene
    }

    /// A single wedge as a 2D path: an outer arc, a line in to the inner
    /// radius (0 for a solid pie slice), an inner arc back, then closed —
    /// exactly the donut-vs-pie shape `PieChartView` draws in 2D, just fed
    /// to `SCNShape` for extrusion instead of a SwiftUI `Path`.
    private static func wedgePath(outerRadius: CGFloat, innerRadius: CGFloat, startAngle: CGFloat, endAngle: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        let outerStart = CGPoint(x: cos(startAngle) * outerRadius, y: sin(startAngle) * outerRadius)
        path.move(to: outerStart)
        path.addArc(withCenter: .zero, radius: outerRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        if innerRadius > 0 {
            let innerEnd = CGPoint(x: cos(endAngle) * innerRadius, y: sin(endAngle) * innerRadius)
            path.addLine(to: innerEnd)
            path.addArc(withCenter: .zero, radius: innerRadius, startAngle: endAngle, endAngle: startAngle, clockwise: false)
        } else {
            path.addLine(to: .zero)
        }
        path.close()
        return path
    }
}
#endif
