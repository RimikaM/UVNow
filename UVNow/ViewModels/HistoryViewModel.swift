import Observation

@MainActor
@Observable
final class HistoryViewModel {

    var monthlyData: [MonthlyUVSummary] = []
    var selectedYearsBack: Int = 3
    var isLoading: Bool = false
    var errorMessage: String?

    private var loadedKey: String?
    private let service = HistoricalUVService()

    func reset() {
        loadedKey = nil
        monthlyData = []
        errorMessage = nil
    }

    func load(latitude: Double, longitude: Double) async {
        let key = "\(String(format: "%.3f", latitude)),\(String(format: "%.3f", longitude))"
        guard key != loadedKey else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            monthlyData = try await service.fetchMonthlyAverages(latitude: latitude, longitude: longitude)
            loadedKey = key
        } catch is CancellationError {
            // Task was cancelled (e.g. location changed mid-flight) — silently ignore.
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Returns only the years that fall within the selected range.
    var displayedYears: [Int] {
        let allYears = Set(monthlyData.map(\.year)).sorted()
        guard !allYears.isEmpty else { return [] }
        let cutoff = (allYears.last ?? 0) - selectedYearsBack + 1
        return allYears.filter { $0 >= cutoff }
    }

    var filteredData: [MonthlyUVSummary] {
        let years = Set(displayedYears)
        return monthlyData.filter { years.contains($0.year) }
    }
}
