import Foundation

struct MonthlyUVSummary: Sendable, Identifiable {
    var id: String { "\(year)-\(month)" }
    let year: Int
    let month: Int
    let averageMax: Double
}
