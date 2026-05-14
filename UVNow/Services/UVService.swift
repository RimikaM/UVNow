import Foundation

struct OpenMeteoService: UVDataProvider {

    let name = "Open-Meteo"
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchUV(latitude: Double, longitude: Double) async throws -> UVReading {
        var components = URLComponents(string: "https://api.open-meteo.com/v1/forecast")!
        components.queryItems = [
            URLQueryItem(name: "latitude",      value: String(format: "%.4f", latitude)),
            URLQueryItem(name: "longitude",     value: String(format: "%.4f", longitude)),
            URLQueryItem(name: "current",       value: "uv_index"),
            URLQueryItem(name: "daily",         value: "uv_index_max"),
            URLQueryItem(name: "hourly",        value: "uv_index"),
            URLQueryItem(name: "timezone",      value: "auto"),
            URLQueryItem(name: "forecast_days", value: "1"),
        ]

        guard let url = components.url else {
            throw UVError.networkError("Invalid URL")
        }

        let (data, response) = try await session.data(from: url)

        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw UVError.networkError("Open-Meteo: bad server response")
        }

        let decoded = try JSONDecoder().decode(OpenMeteoResponse.self, from: data)

        let hourly = zip(decoded.hourly.time, decoded.hourly.uvIndex)
            .compactMap { timeString, uv -> HourlyUVReading? in
                guard let date = Self.hourFormatter.date(from: timeString) else { return nil }
                return HourlyUVReading(time: date, uvIndex: uv)
            }

        return UVReading(
            source: name,
            currentUV: decoded.current.uvIndex,
            dailyMax: decoded.daily.todayMax,
            hourlyReadings: hourly
        )
    }

    private static let hourFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()
}

// MARK: - Internal response types

private struct OpenMeteoResponse: Decodable {
    let current: OpenMeteoCurrent
    let daily: OpenMeteoDaily
    let hourly: OpenMeteoHourly
}

private struct OpenMeteoCurrent: Decodable {
    let uvIndex: Double
    enum CodingKeys: String, CodingKey { case uvIndex = "uv_index" }
}

private struct OpenMeteoDaily: Decodable {
    let uvIndexMax: [Double]
    enum CodingKeys: String, CodingKey { case uvIndexMax = "uv_index_max" }
    var todayMax: Double { uvIndexMax.first ?? 0 }
}

private struct OpenMeteoHourly: Decodable {
    let time: [String]
    let uvIndex: [Double]
    enum CodingKeys: String, CodingKey { case time, uvIndex = "uv_index" }
}
