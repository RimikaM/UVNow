import SwiftUI

struct ContentView: View {
    @State private var uvViewModel     = UVViewModel()
    @State private var historyViewModel = HistoryViewModel()

    var body: some View {
        NowTab(viewModel: uvViewModel)
//        TabView {
//            NowTab(viewModel: uvViewModel)
//                .tabItem { Label("Now", systemImage: "sun.max") }
//
//            HistoryView(uvViewModel: uvViewModel, historyViewModel: historyViewModel)
//                .tabItem { Label("History", systemImage: "chart.line.uptrend.xyaxis") }
//        }
//        // ContentView owns both view models, so this .task reliably fires
//        // whenever coordinates change — even while History tab is inactive.
//        .task(id: "\(uvViewModel.latitude ?? 0),\(uvViewModel.longitude ?? 0)") {
//            guard let lat = uvViewModel.latitude, let lon = uvViewModel.longitude else { return }
//            await historyViewModel.load(latitude: lat, longitude: lon)
//        }
    }
}

// MARK: - Now tab (extracted so TabView doesn't re-init it)

private struct NowTab: View {
    let viewModel: UVViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    LocationSearchView(viewModel: viewModel)

                    SkinTonePickerView(viewModel: viewModel)

                    if viewModel.isLoading {
                        ProgressView("Fetching UV data…")
                            .padding(.top, 40)
                    } else if let error = viewModel.errorMessage {
                        ContentUnavailableView(
                            error,
                            systemImage: "exclamationmark.triangle",
                            description: Text("Please try a different location.")
                        )
                        .padding(.top, 20)
                    } else if let current = viewModel.currentUV,
                              let level = viewModel.uvLevel {
                        UVGaugeView(
                            uvIndex: current,
                            level: level,
                            locationName: viewModel.locationName
                        )

                        if let maxUV = viewModel.todayMaxUV,
                           let maxLevel = viewModel.todayMaxLevel {
                            TodayMaxCard(uvMax: maxUV, level: maxLevel)
                        }

                        if !viewModel.hourlyUV.isEmpty {
                            HourlyUVChart(readings: viewModel.hourlyUV)
                        }

                        SourceReadingsView(
                            readings: viewModel.sourceReadings,
                            sourcesAgree: viewModel.sourcesAgree
                        )

                        ProtectionAdviceView(level: level, skinType: viewModel.skinType)
                    } else {
                        ContentUnavailableView(
                            "Search a Location",
                            systemImage: "sun.max",
                            description: Text("Enter a city name above or tap My Location.")
                        )
                        .padding(.top, 20)
                    }
                }
                .padding()
            }
            .navigationTitle("UV Now")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
