# Chart catalog

The full scope KitoCharts is working toward, modeled on DevKit's ChartKit
catalog. Each row is either shipped, or a tracked gap — this file is the
honest roadmap, not a claim that everything below already exists.

## Cartesian

| Chart | Status | Notes |
| --- | --- | --- |
| Line | ✅ Shipped | `LineChartViewModel` / `LineChartView`. Multi-series, smoothed or straight, drag-to-inspect. |
| Area | 🔲 Planned | Fill under `LineChartView`'s path; shares its ViewModel, adds a `style: .line \| .area` toggle. |
| Bar (vertical/horizontal, grouped) | ✅ Shipped | `BarChartViewModel` / `BarChartView`. |
| Stacked bar | 🔲 Planned | Extend `BarChartViewModel.groupedByLabel` to stack rather than cluster. |
| Scatter | 🔲 Planned | New ViewModel: two-value points (x, y) instead of (label, value). |
| Bubble | 🔲 Planned | Scatter + a third dimension mapped to point radius. |
| Histogram | 🔲 Planned | Binning logic on top of `BarChartViewModel`. |
| Box plot | 🔲 Planned | Needs a `BoxPlotDataPoint` (min/q1/median/q3/max) distinct from `ChartDataPoint`. |
| Violin | 🔲 Planned | Kernel density estimate + mirrored area fill. |
| Heatmap | 🔲 Planned | Grid of `ChartDataPoint` with a 2D `(row, column)` position and a color scale. |
| Calendar heatmap | 🔲 Planned | Heatmap laid out on a week/day grid — GitHub contribution graph shape. |
| Candlestick | 🔲 Planned | OHLC data model; four-value point instead of one. |
| OHLC | 🔲 Planned | Shares the candlestick data model, different mark. |
| Volume | 🔲 Planned | Bar chart variant sharing a time axis with candlestick/OHLC. |
| Waterfall | 🔲 Planned | Running-total bars; needs cumulative-sum logic in the ViewModel. |
| Dumbbell | 🔲 Planned | Two values per category connected by a line. |
| Lollipop | 🔲 Planned | Bar chart variant: stem + dot instead of a filled rectangle. |
| Bullet | 🔲 Planned | KPI-style: target line + qualitative ranges + measure bar. |
| Timeline | 🔲 Planned | Points/spans positioned on a date axis. |
| Range | 🔲 Planned | Band between two values per category. |
| Gantt | 🔲 Planned | Timeline + per-row horizontal bars with start/end dates. |

## Polar

| Chart | Status | Notes |
| --- | --- | --- |
| Pie | ✅ Shipped | `PieChartViewModel` / `PieChartView` with `innerRadiusFraction = 0`. |
| Donut | ✅ Shipped | Same types, `innerRadiusFraction > 0`. |
| Radial bar | 🔲 Planned | Bars swept as arcs instead of laid out linearly — shares `PieChartViewModel`'s angle math. |
| Radar | 🔲 Planned | Multi-axis polygon; needs an N-axis ViewModel distinct from the 2-value chart types. |
| Sunburst | 🔲 Planned | Hierarchical pie — nested `PieSlice` rings. |
| Gauge | 🔲 Planned | Single-value arc against a min/max range with threshold bands. |

## Planar / hierarchical / graph

| Chart | Status | Notes |
| --- | --- | --- |
| Treemap | 🔲 Planned | Squarified layout algorithm over hierarchical data. |
| Sankey | 🔲 Planned | Node/link layout; needs a distinct graph data model. |
| Funnel | 🔲 Planned | Ordered stages, each a trapezoid sized to its value. |
| Network graph | 🔲 Planned | Force-directed layout; heaviest lift in the catalog. |

## 3D

| Chart | Status | Notes |
| --- | --- | --- |
| 3D bar | ✅ Shipped | `Chart3DViewModel` / `Chart3DView`, SceneKit-backed, built-in pinch/rotate/pan. |
| 3D scatter | 🔲 Planned | Same SceneKit scene-builder pattern, `SCNSphere` nodes positioned in 3 dimensions. |
| 3D surface | 🔲 Planned | Heightmap mesh — the most SceneKit-heavy addition. |

## Cross-cutting features (apply once, to every chart)

| Feature | Status | Notes |
| --- | --- | --- |
| Annotations (threshold lines, bands, markers) | 🔲 Planned | A `ChartAnnotation` overlay type composed onto any Cartesian chart. |
| Crosshair / scrubbing | 🟡 Partial | `LineChartView` has drag-to-inspect; not yet generalized to bar/area. |
| Pinch zoom / pan / range selection | 🔲 Planned | Needs a shared `ChartViewport` object multiple charts can bind to for linking. |
| Linked charts / cross-filtering | 🔲 Planned | Depends on `ChartViewport` above. |
| Log / symmetric-log scales | 🔲 Planned | `LinearScale` gets a `LogScale` sibling behind a shared `ChartScale` protocol. |
| Downsampling for large datasets | 🔲 Planned | LTTB or min/max decimation before points reach a ViewModel. |
| Flow adapter for live streams | 🔲 Planned | `AsyncSequence` → ViewModel `.points` binding helper. |
| Static export (image) | 🔲 Planned | `ImageRenderer` wrapper producing a `UIImage` from any chart view. |
| Accessibility (summaries, data table, VoiceOver) | 🔲 Planned | Each ViewModel gains a `accessibilitySummary: String`; a `.kitoDataTable()` modifier exposes raw values. |

## How to pick up an item

1. New chart types get their own `XChartViewModel` (state) + `XChartView`
   (pure rendering) pair under `ViewModels/` and `Views/`, following
   `LineChartViewModel`/`LineChartView` as the template.
2. Reuse `LinearScale`, `ValueAxis`, `ChartLegend`, and `KitoChartTheme` —
   don't re-derive scaling or theming per chart.
3. Add a test file mirroring `KitoChartsTests.swift`'s style: pure logic
   (scale math, slice math, grouping) is unit-testable without rendering.
4. Flip the row above from 🔲 to ✅ in the same PR.
