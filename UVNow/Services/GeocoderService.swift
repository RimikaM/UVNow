import CoreLocation

struct GeocoderService: Sendable {

    func coordinate(for locationName: String) async throws -> CLLocationCoordinate2D {
        let geocoder = CLGeocoder()
        return try await withCheckedThrowingContinuation { continuation in
            geocoder.geocodeAddressString(locationName) { placemarks, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let coordinate = placemarks?.first?.location?.coordinate else {
                    continuation.resume(throwing: UVError.locationNotFound)
                    return
                }
                continuation.resume(returning: coordinate)
            }
        }
    }
}

enum UVError: LocalizedError, Sendable {
    case locationNotFound
    case networkError(String)

    var errorDescription: String? {
        switch self {
        case .locationNotFound:
            return "Location not found. Try a different city name."
        case .networkError(let msg):
            return "Network error: \(msg)"
        }
    }
}
