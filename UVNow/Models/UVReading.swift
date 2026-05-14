import Foundation

/// A single hourly UV data point.
struct HourlyUVReading: Sendable, Identifiable {
    var id: Date { time }
    let time: Date
    let uvIndex: Double
}

/// A UV observation returned by any data source.
struct UVReading: Sendable {
    let source: String
    let currentUV: Double
    let dailyMax: Double
    /// Hourly UV readings for today. Nil if the source doesn't provide hourly data.
    let hourlyReadings: [HourlyUVReading]?
}

/// Any UV data provider — Open-Meteo, OpenUV, WeatherKit, etc.
/// Add a new source by creating a struct that conforms to this protocol
/// and appending it to the `providers` array in UVViewModel.
protocol UVDataProvider: Sendable {
    var name: String { get }
    func fetchUV(latitude: Double, longitude: Double) async throws -> UVReading
}
