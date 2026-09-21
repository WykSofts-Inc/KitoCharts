//
//  Chart3DPieView.swift
//  KitoCharts
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore
#if canImport(SceneKit)
import SceneKit

/// A real 3D pie/donut chart — drag to rotate, pinch to zoom, two-finger
/// pan, same as `Chart3DView`. Bind a `Chart3DPieViewModel`.
public struct Chart3DPieView: View {
    let viewModel: Chart3DPieViewModel

    public init(viewModel: Chart3DPieViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        SceneKitView(scene: viewModel.scene)
            .frame(minHeight: 260)
    }
}
#else
public struct Chart3DPieView: View {
    public init(viewModel: Chart3DPieViewModel) {}
    public var body: some View {
        Text("3D charts require SceneKit")
            .font(.caption)
            .foregroundStyle(.secondary)
    }
}
#endif
