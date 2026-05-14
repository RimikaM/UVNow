import WeatherKit
import CoreLocation

struct WeatherKitService: UVDataProvider {
    let name = "WeatherKit"

    func fetchUV(latitude: Double, longitude: Double) async throws -> UVReading {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let weather = try await WeatherService.shared.weather(
            for: location,
            including: .current, .daily, .hourly
        )
        let current = Double(weather.0.uvIndex.value)
        let dailyMax = weather.1.first.map { Double($0.uvIndex.value) } ?? current
        let hourly: [HourlyUVReading] = weather.2.map {
            HourlyUVReading(time: $0.date, uvIndex: Double($0.uvIndex.value))
        }
        return UVReading(source: name, currentUV: current, dailyMax: dailyMax, hourlyReadings: hourly)
    }
}
