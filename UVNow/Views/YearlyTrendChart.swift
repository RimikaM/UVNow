import Charts
import SwiftUI

struct YearlyTrendChart: View {
    let data: [MonthlyUVSummary]
    let years: [Int]

    private static let monthAbbrevs = ["Jan","Feb","Mar","Apr","May","Jun",
                                        "Jul","Aug","Sep","Oct","Nov","Dec"]

    var body: some View {
        Chart {
            ForEach(years, id: \.self) { year in
                ForEach(data.filter { $0.year == year }) { point in
                    LineMark(
                        x: .value("Month", point.month),
                        y: .value("UV Max", point.averageMax)
                    )
                    .foregroundStyle(by: .value("Year", String(year)))
                    .interpolationMethod(.catmullRom)
                    .symbol(Circle())
                    .symbolSize(30)
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: Array(1...12)) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let month = value.as(Int.self) {
                        Text(Self.monthAbbrevs[month - 1])
                            .font(.caption2)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { _ in
                AxisGridLine()
                AxisValueLabel()
            }
        }
        .chartLegend(position: .top, alignment: .trailing)
        .frame(height: 220)
    }
}
