import Foundation

struct OpenUVService: UVDataProvider {

    let name = "OpenUV"
    let apiKey: String
    private let session: URLSession

    init(apiKey: String, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
    }

    func fetchUV(latitude: Double, longitude: Double) async throws -> UVReading {
        var components = URLComponents(string: "https://api.openuv.io/api/v1/uv")!
        components.queryItems = [
            URLQueryItem(name: "lat", value: String(format: "%.4f", latitude)),
            URLQueryItem(name: "lng", value: String(format: "%.4f", longitude)),
        ]

        guard let url = components.url else {
            throw UVError.networkError("OpenUV: invalid URL")
        }

        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "x-access-token")

        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw UVError.networkError("OpenUV: no response")
        }

        if http.statusCode == 429 {
            throw UVError.networkError("OpenUV: daily request limit reached")
        }

        guard (200..<300).contains(http.statusCode) else {
            throw UVError.networkError("OpenUV: HTTP \(http.statusCode)")
        }

        let decoded = try JSONDecoder().decode(OpenUVResponse.self, from: data)
        return UVReading(
            source: name,
            currentUV: decoded.result.uv,
            dailyMax: decoded.result.uvMax,
            hourlyReadings: nil
        )
    }
}

// MARK: - Internal response types

private struct OpenUVResponse: Decodable {
    let result: OpenUVResult
}

private struct OpenUVResult: Decodable {
    let uv: Double
    let uvMax: Double
    enum CodingKeys: String, CodingKey {
        case uv
        case uvMax = "uv_max"
    }
}
