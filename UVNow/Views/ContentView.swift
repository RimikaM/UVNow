import SwiftUI

struct ContentView: View {
    @State private var uvViewModel     = UVViewModel()
    @State private var historyViewModel = HistoryViewModel()

    var preferredColorScheme: ColorScheme? {
        switch uvViewModel.colorSchemeRaw {
        case 1: return .light
        case 2: return .dark
        default: return nil
        }
    }

    var body: some View {
        NowTab(viewModel: uvViewModel)
            .preferredColorScheme(preferredColorScheme)
            .task { await uvViewModel.restoreSavedLocation() }
    }
}

// MARK: - Now tab

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
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.colorSchemeRaw = (viewModel.colorSchemeRaw + 1) % 3
                    } label: {
                        Image(systemName: colorSchemeIcon(viewModel.colorSchemeRaw))
                    }
                }
            }
        }
    }

    private func colorSchemeIcon(_ raw: Int) -> String {
        switch raw {
        case 1: return "sun.max.fill"
        case 2: return "moon.fill"
        default: return "circle.lefthalf.filled"
        }
    }
}
