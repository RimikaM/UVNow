import CoreLocation
import Observation

@MainActor
@Observable
final class UVViewModel {

    // MARK: - State

    var locationInput: String = ""
    var currentUV: Double?
    var todayMaxUV: Double?
    var sourceReadings: [UVReading] = []
    var hourlyUV: [HourlyUVReading] = []
    var isLoading: Bool = false
    var errorMessage: String?
    var locationName: String = ""
    private(set) var latitude: Double?
    private(set) var longitude: Double?

    var skinTypeRaw: Int = max(1, UserDefaults.standard.integer(forKey: "skinTypeRaw")) {
        didSet { UserDefaults.standard.set(skinTypeRaw, forKey: "skinTypeRaw") }
    }

    var colorSchemeRaw: Int = UserDefaults.standard.integer(forKey: "colorSchemeRaw") {
        didSet { UserDefaults.standard.set(colorSchemeRaw, forKey: "colorSchemeRaw") }
    }

    // MARK: - Computed

    var uvLevel: UVLevel? { currentUV.map { UVLevel(uvIndex: $0) } }
    var todayMaxLevel: UVLevel? { todayMaxUV.map { UVLevel(uvIndex: $0) } }
    var skinType: FitzpatrickType { FitzpatrickType(rawValue: skinTypeRaw) ?? .typeI }

    /// True when multiple sources returned values and their current UV differs by ≤ 1.0.
    var sourcesAgree: Bool {
        guard sourceReadings.count > 1 else { return true }
        let values = sourceReadings.map(\.currentUV)
        return (values.max()! - values.min()!) <= 1.0
    }

    // MARK: - Providers
    // To add WeatherKit: append WeatherKitService() here.
    // To remove OpenUV: delete it from this array.

    private let providers: [any UVDataProvider] = {
        var list: [any UVDataProvider] = [OpenMeteoService(), WeatherKitService()]
        if !Config.openUVApiKey.isEmpty {
            list.append(OpenUVService(apiKey: Config.openUVApiKey))
        }
        return list
    }()

    // MARK: - Services

    private let geocoderService = GeocoderService()
    private let locationManager = LocationManager()

    // MARK: - Actions

    func restoreSavedLocation() async {
        let name = UserDefaults.standard.string(forKey: "savedLocationName") ?? ""
        let lat  = UserDefaults.standard.double(forKey: "savedLatitude")
        let lon  = UserDefaults.standard.double(forKey: "savedLongitude")
        guard !name.isEmpty, lat != 0, lon != 0 else { return }
        locationInput = name
        locationName  = name
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        try? await loadUV(latitude: lat, longitude: lon)
    }

    func searchLocation() async {
        let query = locationInput.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return }
        await fetchUV(for: query)
    }

    func useCurrentLocation() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let coordinate = try await locationManager.requestLocation()
            let geocoder = CLGeocoder()
            let placemarks = try? await geocoder.reverseGeocodeLocation(
                CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            )
            locationName = placemarks?.first?.locality ?? "Current Location"
            locationInput = locationName
            try await loadUV(latitude: coordinate.latitude, longitude: coordinate.longitude)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Private

    private func fetchUV(for city: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let coordinate = try await geocoderService.coordinate(for: city)
            locationName = city
            try await loadUV(latitude: coordinate.latitude, longitude: coordinate.longitude)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loadUV(latitude: Double, longitude: Double) async throws {
        self.latitude  = latitude
        self.longitude = longitude
        UserDefaults.standard.set(locationName, forKey: "savedLocationName")
        UserDefaults.standard.set(latitude,     forKey: "savedLatitude")
        UserDefaults.standard.set(longitude,    forKey: "savedLongitude")
        // Fan out to all providers concurrently; failed providers are silently dropped.
        let readings: [UVReading] = await withTaskGroup(of: UVReading?.self) { group in
            for provider in providers {
                group.addTask {
                    do {
                        return try await provider.fetchUV(latitude: latitude, longitude: longitude)
                    } catch {
                        print("[\(provider.name)] failed: \(error)")
                        return nil
                    }
                }
            }
            var results: [UVReading] = []
            for await reading in group {
                if let r = reading { results.append(r) }
            }
            return results.sorted { $0.source < $1.source }
        }

        guard !readings.isEmpty else {
            throw UVError.networkError("All data sources failed to respond")
        }

        sourceReadings = readings
        currentUV  = readings.map(\.currentUV).reduce(0, +) / Double(readings.count)
        todayMaxUV = readings.map(\.dailyMax).reduce(0, +)  / Double(readings.count)
        hourlyUV   = readings.compactMap(\.hourlyReadings).first ?? []
    }
}
