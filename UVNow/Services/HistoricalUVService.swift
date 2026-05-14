import Foundation

struct HistoricalUVService: Sendable {

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    /// Fetches 5 years of daily UV max and returns monthly averages.
    func fetchMonthlyAverages(latitude: Double, longitude: Double) async throws -> [MonthlyUVSummary] {
        let calendar = Calendar(identifier: .gregorian)
        // Archive lags ~5 days; use 7 days ago as end_date to guarantee data is available.
        let endDate   = calendar.date(byAdding: .day, value: -7, to: Date())!
        let startDate = calendar.date(byAdding: .year, value: -5, to: endDate)!

        var components = URLComponents(string: "https://archive-api.open-meteo.com/v1/archive")!
        components.queryItems = [
            URLQueryItem(name: "latitude",   value: String(format: "%.4f", latitude)),
            URLQueryItem(name: "longitude",  value: String(format: "%.4f", longitude)),
            URLQueryItem(name: "start_date", value: Self.dateString(startDate)),
            URLQueryItem(name: "end_date",   value: Self.dateString(endDate)),
            URLQueryItem(name: "daily",      value: "uv_index_max"),
            URLQueryItem(name: "timezone",   value: "auto"),
        ]

        guard let url = components.url else {
            throw UVError.networkError("HistoricalUVService: invalid URL")
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw UVError.networkError("Historical API: bad server response")
        }

        let decoded = try JSONDecoder().decode(HistoricalResponse.self, from: data)
        return aggregate(times: decoded.daily.time, values: decoded.daily.uvIndexMax)
    }

    // MARK: - Private

    private func aggregate(times: [String], values: [Double?]) -> [MonthlyUVSummary] {
        var groups: [Int: [Int: [Double]]] = [:]  // [year: [month: [daily maxes]]]

        for (dateStr, value) in zip(times, values) {
            guard let value, let date = Self.dayFormatter.date(from: dateStr) else { continue }
            let cal = Calendar(identifier: .gregorian)
            let year  = cal.component(.year,  from: date)
            let month = cal.component(.month, from: date)
            groups[year, default: [:]][month, default: []].append(value)
        }

        return groups.flatMap { year, months in
            months.map { month, dayValues in
                MonthlyUVSummary(
                    year: year,
                    month: month,
                    averageMax: dayValues.reduce(0, +) / Double(dayValues.count)
                )
            }
        }
        .sorted { ($0.year, $0.month) < ($1.year, $1.month) }
    }

    private static func dateString(_ date: Date) -> String {
        dayFormatter.string(from: date)
    }

    private static let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()
}

// MARK: - Response types

private struct HistoricalResponse: Decodable {
    let daily: HistoricalDaily
}

private struct HistoricalDaily: Decodable {
    let time: [String]
    let uvIndexMax: [Double?]
    enum CodingKeys: String, CodingKey { case time, uvIndexMax = "uv_index_max" }
}
