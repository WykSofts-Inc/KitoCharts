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

## Architecture

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) — this package is the
reference implementation of Kito's MVVM conventions (also documented at the
[KitoDevKit](https://github.com/WykSofts-Inc/KitoDevKit) umbrella level).

## License

MIT
