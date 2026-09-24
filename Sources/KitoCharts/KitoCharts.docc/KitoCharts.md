# ``KitoCharts``

MVVM line, bar, pie, and 3D charts for SwiftUI with one shared theme and scale engine.

## Overview

KitoCharts provides line, bar, pie and donut, and SceneKit-rendered 3D bar and
pie charts. Every chart type sits on the same scale, axis, and legend engine and
reads the same ``KitoChartTheme``, so charts across an app look consistent.

Every chart follows the same shape: an array of ``ChartDataPoint`` values, an
`@Observable` view model that owns selection and animation state, and a view
that is a pure function of that view model.

```swift
import SwiftUI
import KitoCharts

struct SalesView: View {
    @State private var viewModel = LineChartViewModel(points: [
        ChartDataPoint(label: "Mon", value: 120),
        ChartDataPoint(label: "Tue", value: 200),
        ChartDataPoint(label: "Wed", value: 150),
        ChartDataPoint(label: "Thu", value: 260),
    ])

    var body: some View {
        LineChartView(viewModel: viewModel, style: .area)
            .kitoChartTheme(.default)
            .padding()
    }
}
```

``LineChartStyle`` controls everything about how a line looks: interpolation,
point markers, area fill, gradients, and reference lines, with ready-made
`sparkline` and `area` presets. Apply a theme once near the root with
`kitoChartTheme(_:)` to retint every chart in the tree; charts read it with
`@Environment(\.kitoChartTheme)`.

The 3D charts render with SceneKit and support pinch, rotate, and pan through
its built-in camera control. After mutating a 3D view model's `points`, call
its `rebuild()` method, because SceneKit scenes are not observable the way
SwiftUI state is.

## Topics

### Data and Theming

- ``ChartDataPoint``
- ``KitoChartTheme``

### Line Charts

- ``LineChartView``
- ``LineChartViewModel``
- ``LineChartStyle``
- ``LineInterpolation``
- ``LinePointStyle``
- ``LineAreaFill``
- ``LineReferenceLine``

### Bar Charts

- ``BarChartView``
- ``BarChartViewModel``

### Pie and Donut Charts

- ``PieChartView``
- ``PieChartViewModel``
- ``PieSlice``

### 3D Charts

- ``Chart3DView``
- ``Chart3DViewModel``
- ``Chart3DPieView``
- ``Chart3DPieViewModel``

### Building Blocks

- ``LinearScale``
- ``ValueAxis``
- ``ChartLegend``
