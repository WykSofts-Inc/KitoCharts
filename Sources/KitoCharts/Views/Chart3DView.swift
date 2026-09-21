//
//  Chart3DView.swift
//  KitoCharts
//
//  Created by Wycliff on 1/23/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
#if canImport(SceneKit)
import SceneKit

/// 3D bar chart rendered with SceneKit — no ARKit, no camera permission, just
/// an `SCNView` the user can pinch/rotate/pan (`allowsCameraControl`). Bind a
/// `Chart3DViewModel`; call `rebuild()` on it after mutating `points` since
/// SceneKit scenes aren't observable the way SwiftUI state is.
public struct Chart3DView: View {
    let viewModel: Chart3DViewModel

    public init(viewModel: Chart3DViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        SceneKitView(scene: viewModel.scene)
            .frame(minHeight: 260)
    }
}

/// Shared by every SceneKit-backed chart view in this package (bar, pie) —
/// not `private` so `Chart3DPieView` can reuse it too.
struct SceneKitView: UIViewRepresentable {
    let scene: SCNScene

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.scene = scene
        view.allowsCameraControl = true
        view.autoenablesDefaultLighting = false
        view.backgroundColor = .clear
        return view
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        uiView.scene = scene
    }
}
#else
/// SceneKit is unavailable on this platform. Kept so the package still
/// compiles everywhere KitoCharts is imported; the type simply renders nothing.
public struct Chart3DView: View {
    public init(viewModel: Chart3DViewModel) {}
    public var body: some View {
        Text("3D charts require SceneKit")
            .font(.caption)
            .foregroundStyle(.secondary)
    }
}
#endif
