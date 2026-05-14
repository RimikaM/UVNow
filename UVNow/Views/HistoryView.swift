import SwiftUI

struct HistoryView: View {
    let uvViewModel: UVViewModel
    @Bindable var historyViewModel: HistoryViewModel

    private let rangeOptions = [1, 2, 3, 5]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if uvViewModel.latitude == nil {
                        ContentUnavailableView(
                            "No Location Selected",
                            systemImage: "mappin.slash",
                            description: Text("Search a location on the Now tab first.")
                        )
                        .padding(.top, 40)
                    } else if historyViewModel.isLoading {
                        ProgressView("Loading historical data…")
                            .padding(.top, 40)
                    } else if let error = historyViewModel.errorMessage {
                        ContentUnavailableView {
                            Label("Couldn't Load History", systemImage: "exclamationmark.triangle")
                        } description: {
                            Text(error)
                        } actions: {
                            Button("Try Again") {
                                Task {
                                    guard let lat = uvViewModel.latitude,
                                          let lon = uvViewModel.longitude else { return }
                                    historyViewModel.reset()
                                    await historyViewModel.load(latitude: lat, longitude: lon)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.top, 40)
                    } else if historyViewModel.monthlyData.isEmpty {
                        ProgressView("Loading historical data…")
                            .padding(.top, 40)
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("UV Index Trends")
                                        .font(.headline)
                                    Text(uvViewModel.locationName)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Picker("Range", selection: $historyViewModel.selectedYearsBack) {
                                    ForEach(rangeOptions, id: \.self) { y in
                                        Text("\(y)Y").tag(y)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .fixedSize()
                            }

                            YearlyTrendChart(
                                data: historyViewModel.filteredData,
                                years: historyViewModel.displayedYears
                            )

                            Text("Monthly average of daily UV max · Source: Open-Meteo ERA5")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                    }
                }
                .padding()
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
