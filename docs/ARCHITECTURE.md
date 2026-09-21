# Architecture — MVVM across Kito

KitoCharts is the reference implementation for how every Kito kit does MVVM.
This document is duplicated (not linked) into each kit's own `docs/` so it
survives being read kit-by-kit — keep copies in sync when the convention changes.

## The contract

- **Model**: plain value types. `ChartDataPoint` has no behavior, no
  `@Observable`, no reference to SwiftUI beyond `Color`. Models are
  `Equatable`/`Sendable` wherever possible so ViewModels and tests can compare
  them cheaply.
- **ViewModel**: an `@Observable final class` conforming to `KitoViewModel`
  (from KitoCore). Owns *all* mutable state for its screen or component:
  data, selection, animation progress, derived/computed values. Exposes
  intents as methods (`select(_:)`, `reveal(duration:)`) — never lets a view
  mutate its properties as a side effect of rendering.
- **View**: a `struct: View` that takes a ViewModel via `@Bindable` (when the
  view needs two-way binding, e.g. a form field) or as a plain `let` (when
  read-only, e.g. a chart). Views compute layout/geometry and call ViewModel
  intents in response to gestures. A view **never** owns business state in
  `@State` — the only acceptable `@State` in a Kito view is pure UI ephemera
  that has no meaning outside that view's lifetime (e.g. `@State private var
  isPressed = false` for a button's visual depression).

## Why `@Observable` over `ObservableObject`

Swift's Observation framework (`@Observable`, iOS 17+) tracks property-level
access, so a view that reads `viewModel.selectedPointID` doesn't re-render when
`viewModel.points` changes. `ObservableObject`'s `@Published` re-renders on
*any* published change. For charts with per-frame animation state, that
difference is the gap between smooth and janky. This is why every Kito
package targets iOS 17+ rather than iOS 16.

## Testing implication

Because ViewModels hold no SwiftUI view state, they're testable without
`ViewInspector` or snapshot tooling — see `KitoChartsTests.swift`:
`PieChartViewModel().slices` is asserted on directly, no rendering involved.
Every new chart type should ship ViewModel tests before view polish.

## Dependency injection

ViewModels take their initial data via `init`, never reach into a singleton
or environment for it. A screen assembles its ViewModel (optionally injecting
a repository/service) and hands it to the view:

```swift
struct DashboardScreen: View {
    @State private var salesViewModel = LineChartViewModel(points: SalesRepository.recent())

    var body: some View {
        LineChartView(viewModel: salesViewModel)
    }
}
```

`KitoScreens` follows the same shape: each prebuilt screen (`SignInScreen`,
`CardCheckoutScreen`, …) pairs with a `SignInViewModel`, `CardCheckoutViewModel`,
etc. A consumer who wants custom networking/validation subclasses or
re-implements the ViewModel and drops it into the stock View — the View
never assumes a concrete data source, only the ViewModel's public interface.

## What breaks this contract (don't do these)

- A view computing a scale, slice angle, or grouping *itself* instead of
  reading it from the ViewModel — duplicates logic the ViewModel already owns
  and desyncs the moment one side changes.
- A ViewModel importing `SwiftUI` for anything beyond `Color`/`Animation`
  types — keeps ViewModels testable on Linux/without a simulator.
- Two-way `@Bindable` on a chart ViewModel a user can't actually edit (charts
  are read-mostly; only forms need true two-way binding). Prefer `let` +
  intent methods when the view never writes back.
