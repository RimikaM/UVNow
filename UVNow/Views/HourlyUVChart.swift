import Charts
import SwiftUI

struct HourlyUVChart: View {
    let readings: [HourlyUVReading]

    private var visibleReadings: [HourlyUVReading] {
        readings.filter { $0.uvIndex > 0 }
    }

    private var now: Date { Date() }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's UV by Hour")
                .font(.headline)

            if visibleReadings.isEmpty {
                Text("No UV exposure expected today.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
            } else {
                Chart {
                    ForEach(readings) { reading in
                        BarMark(
                            x: .value("Hour", reading.time, unit: .hour),
                            y: .value("UV", reading.uvIndex)
                        )
                        .foregroundStyle(barColor(for: reading.uvIndex))
                        .cornerRadius(4)
                    }

                    // "Now" rule mark
                    RuleMark(x: .value("Now", now))
                        .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                        .foregroundStyle(.secondary)
                        .annotation(position: .top, alignment: .center) {
                            Text("now")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .hour, count: 3)) { value in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.hour(.defaultDigits(amPM: .abbreviated)))
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        AxisValueLabel()
                    }
                }
                .chartYScale(domain: 0...(maxUV + 1))
                .frame(height: 160)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var maxUV: Double {
        readings.map(\.uvIndex).max() ?? 11
    }

    private func barColor(for uvIndex: Double) -> Color {
        UVLevel(uvIndex: uvIndex).color
    }
}
