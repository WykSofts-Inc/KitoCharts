# KitoCharts

Compose-native, MVVM charting for SwiftUI — line, bar, pie/donut, and 3D bar
charts today; a full DevKit-ChartKit-equivalent catalog on the roadmap (see
[docs/CHART_CATALOG.md](docs/CHART_CATALOG.md)). One shared theme, one shared
scale/axis/legend engine underneath every chart type.

## Install

```swift
.package(url: "https://github.com/WykSofts-Inc/KitoCharts.git", from: "1.0.0"),
```

## Use

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
        LineChartView(viewModel: viewModel)
            .kitoChartTheme(.default)
            .padding()
    }
}
```

Every chart follows the same shape: a `ChartDataPoint` array, an `@Observable`
ViewModel that owns selection/animation state, and a View that is a pure
function of that ViewModel.

```swift
// Bar
@State var bars = BarChartViewModel(points: data)
BarChartView(viewModel: bars)

// Pie / donut (donut = non-zero innerRadiusFraction)
@State var pie = PieChartViewModel(points: data, innerRadiusFraction: 0.6)
PieChartView(viewModel: pie)

// 3D bars — pinch/rotate/pan built in via SceneKit's allowsCameraControl
@State var chart3D = Chart3DViewModel(points: data)
Chart3DView(viewModel: chart3D)
```

## Line styles

`LineChartView` takes a `LineChartStyle` for everything about how the line looks:

```swift
LineChartView(viewModel: viewModel, style: LineChartStyle(
    interpolation: .catmullRom,          // .linear, .smooth, .catmullRom, .stepped
    points: .hollow,                     // .filled, .hollow, .halo, .lastPoint (pulsing)
    area: .gradient(opacity: 0.35),      // or .solid(opacity:)
    showsLabels: true,                   // x-axis labels, thinned when crowded
    referenceLines: [LineReferenceLine("Goal", value: 250, color: .green)]
))

LineChartView(viewModel: viewModel, style: .sparkline)   // axis-free, for rows and tiles
LineChartView(viewModel: viewModel, style: .area)        // filled area chart
```

Also: `lineWidth`, `dash`, `pointSize`, `strokeGradient`, `glows`, `showsValueAxis`,
`showsValues`, `includesZero` and `animatesIn`. The default style draws exactly what
`LineChartView` always drew.

## Theming

```swift
ContentView()
    .kitoChartTheme(KitoChartTheme(
        categoricalPalette: [.blue, .purple, .pink],
        showGridlines: false,
        animationDuration: 0.35
    ))
```

Every chart reads `@Environment(\.kitoChartTheme)`. Set it once at the root to
retint every chart in the tree.

## Right-to-left

Line and bar charts mirror automatically in right-to-left layouts: the value axis sits on the
leading (right) edge and the first data point is drawn at the leading side, so time runs
right to left. Scrubbing a `LineChartView` follows the finger in both directions, and the pie
chart's selected-slice share is formatted for the current locale. Pie slices run
counter-clockwise under RTL. Pass a locale-aware `valueFormatter` for axis and value labels.

## Architecture

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) — this package is the
reference implementation of Kito's MVVM conventions (also documented at the
[KitoDevKit](https://github.com/WykSofts-Inc/KitoDevKit) umbrella level).

## License

MIT
