import SwiftUI

enum FitzpatrickType: Int, CaseIterable, Sendable {
    case typeI   = 1
    case typeII  = 2
    case typeIII = 3
    case typeIV  = 4
    case typeV   = 5
    case typeVI  = 6

    var label: String { "Type \(romanNumeral)" }

    var description: String {
        switch self {
        case .typeI:   return "Very fair · Always burns, never tans"
        case .typeII:  return "Fair · Usually burns, tans minimally"
        case .typeIII: return "Medium · Sometimes burns, gradually tans"
        case .typeIV:  return "Olive · Rarely burns, tans easily"
        case .typeV:   return "Brown · Very rarely burns"
        case .typeVI:  return "Dark · Never burns"
        }
    }

    var swatchColor: Color {
        switch self {
        case .typeI:   return Color(red: 0.973, green: 0.855, blue: 0.776)
        case .typeII:  return Color(red: 0.953, green: 0.773, blue: 0.627)
        case .typeIII: return Color(red: 0.910, green: 0.659, blue: 0.471)
        case .typeIV:  return Color(red: 0.776, green: 0.525, blue: 0.259)
        case .typeV:   return Color(red: 0.553, green: 0.333, blue: 0.141)
        case .typeVI:  return Color(red: 0.290, green: 0.157, blue: 0.071)
        }
    }

    /// Returns the recommended SPF for this skin type at a given UV level.
    /// Returns nil when no sunscreen is needed.
    func recommendedSPF(for level: UVLevel) -> String? {
        switch sensitivityGroup {
        case 1: // Types I–II: most sensitive
            switch level {
            case .low:                return "SPF 30"
            case .moderate, .high,
                 .veryHigh, .extreme: return "SPF 50+"
            }
        case 2: // Types III–IV: medium
            switch level {
            case .low:               return nil
            case .moderate:          return "SPF 30"
            case .high, .veryHigh,
                 .extreme:           return "SPF 50+"
            }
        default: // Types V–VI: least sensitive
            switch level {
            case .low, .moderate:    return nil
            case .high:              return "SPF 30"
            case .veryHigh, .extreme: return "SPF 50+"
            }
        }
    }

    // MARK: - Private

    private var sensitivityGroup: Int {
        switch self {
        case .typeI, .typeII:   return 1
        case .typeIII, .typeIV: return 2
        case .typeV, .typeVI:   return 3
        }
    }

    private var romanNumeral: String {
        ["I", "II", "III", "IV", "V", "VI"][rawValue - 1]
    }
}
