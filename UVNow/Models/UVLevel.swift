import SwiftUI

enum UVLevel: String, Sendable {
    case low      = "Low"
    case moderate = "Moderate"
    case high     = "High"
    case veryHigh = "Very High"
    case extreme  = "Extreme"

    init(uvIndex: Double) {
        switch uvIndex {
        case ..<3:   self = .low
        case 3..<6:  self = .moderate
        case 6..<8:  self = .high
        case 8..<11: self = .veryHigh
        default:     self = .extreme
        }
    }

    var color: Color {
        switch self {
        case .low:      return Color(red: 0.18, green: 0.72, blue: 0.18)
        case .moderate: return Color(red: 1.0,  green: 0.84, blue: 0.0)
        case .high:     return Color(red: 1.0,  green: 0.55, blue: 0.0)
        case .veryHigh: return Color(red: 0.9,  green: 0.1,  blue: 0.1)
        case .extreme:  return Color(red: 0.56, green: 0.0,  blue: 0.56)
        }
    }

    var advice: String {
        switch self {
        case .low:
            return "No protection needed. Safe to be outside."
        case .moderate:
            return "Wear sunscreen SPF 30+. Seek shade during midday."
        case .high:
            return "Sunscreen SPF 50+, hat, and UV-blocking sunglasses required."
        case .veryHigh:
            return "Minimize sun exposure 10am–4pm. Full coverage clothing, SPF 50+."
        case .extreme:
            return "Avoid the sun entirely if possible. All precautions essential."
        }
    }

    var symbol: String {
        switch self {
        case .low:      return "sun.min"
        case .moderate: return "sun.max"
        case .high:     return "sun.max.fill"
        case .veryHigh: return "sun.horizon.fill"
        case .extreme:  return "exclamationmark.triangle.fill"
        }
    }

    /// Tips with the sunscreen row removed — used when a personalized SPF row is shown instead.
    var behavioralTips: [(icon: String, text: String)] {
        tips.filter { $0.icon != "drop.fill" }
    }

    var tips: [(icon: String, text: String)] {
        switch self {
        case .low:
            return [("checkmark.seal.fill", "No special protection needed")]
        case .moderate:
            return [
                ("drop.fill", "Sunscreen SPF 30+"),
                ("umbrella.fill", "Seek shade at midday"),
            ]
        case .high:
            return [
                ("drop.fill", "Sunscreen SPF 50+"),
                ("hat.widebrim.fill", "Wear a wide-brim hat"),
                ("sunglasses.fill", "UV-blocking sunglasses"),
            ]
        case .veryHigh:
            return [
                ("drop.fill", "Sunscreen SPF 50+"),
                ("hat.widebrim.fill", "Hat and protective clothing"),
                ("clock.fill", "Avoid 10am–4pm sun"),
                ("sunglasses.fill", "Sunglasses essential"),
            ]
        case .extreme:
            return [
                ("xmark.circle.fill", "Avoid outdoor exposure"),
                ("drop.fill", "SPF 50+ even indoors near windows"),
                ("house.fill", "Stay indoors where possible"),
                ("clock.fill", "Reschedule outdoor activities"),
            ]
        }
    }
}
