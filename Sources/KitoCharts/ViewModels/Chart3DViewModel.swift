//
//  Chart3DViewModel.swift
//  KitoCharts
//
//  Created by Wycliff on 1/19/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import Observation
import KitoCore
#if canImport(SceneKit)
import SceneKit
#endif

#if canImport(SceneKit)
/// Owns the 3D bar-chart scene: builds an `SCNScene` from data points and
/// rebuilds it when data changes. The view never touches SceneKit nodes
/// directly — it hands this view model's `scene` to an `SCNView`.
@Observable
public final class Chart3DViewModel: KitoViewModel {
    public var points: [ChartDataPoint]
    public var theme: KitoChartTheme
    public private(set) var scene: SCNScene

    public init(points: [ChartDataPoint], theme: KitoChartTheme = .default) {
        self.points = points
        self.theme = theme
        self.scene = Chart3DViewModel.buildScene(points: points, theme: theme)
    }

    public func rebuild() {
        scene = Chart3DViewModel.buildScene(points: points, theme: theme)
    }

    private static func buildScene(points: [ChartDataPoint], theme: KitoChartTheme) -> SCNScene {
        let scene = SCNScene()
        let maxValue = max(points.map(\.value).max() ?? 1, 0.0001)
        let barWidth: CGFloat = 0.6
        let spacing: CGFloat = 1.2
        let maxHeight: CGFloat = 4.0

        let floor = SCNFloor()
        floor.reflectivity = 0
        floor.firstMaterial?.diffuse.contents = UIColor.systemGray6
        let floorNode = SCNNode(geometry: floor)
        floorNode.position = SCNVector3(0, 0, 0)
        scene.rootNode.addChildNode(floorNode)

        let startX = -CGFloat(points.count - 1) * spacing / 2

        for (index, point) in points.enumerated() {
            let height = max(CGFloat(point.value / maxValue) * maxHeight, 0.02)
            let box = SCNBox(width: barWidth, height: height, length: barWidth, chamferRadius: 0.04)
            let color = point.color ?? theme.color(forCategoryIndex: index)
            box.firstMaterial?.diffuse.contents = UIColor(color)
            box.firstMaterial?.specular.contents = UIColor.white

            let node = SCNNode(geometry: box)
            node.position = SCNVector3(Float(startX + CGFloat(index) * spacing), Float(height / 2), 0)
            scene.rootNode.addChildNode(node)
        }

        let camera = SCNCamera()
        camera.fieldOfView = 45
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 4, Float(points.count) * 1.6 + 3)
        cameraNode.look(at: SCNVector3(0, 1, 0))
        scene.rootNode.addChildNode(cameraNode)

        let light = SCNLight()
        light.type = .omni
        light.intensity = 1200
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(0, 8, 8)
        scene.rootNode.addChildNode(lightNode)

        let ambient = SCNLight()
        ambient.type = .ambient
        ambient.intensity = 400
        let ambientNode = SCNNode()
        ambientNode.light = ambient
        scene.rootNode.addChildNode(ambientNode)

        return scene
    }
}
#endif
