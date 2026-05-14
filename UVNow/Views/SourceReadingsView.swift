import SwiftUI

struct SourceReadingsView: View {
    let readings: [UVReading]
    let sourcesAgree: Bool

    private var spread: Double {
        guard readings.count > 1 else { return 0 }
        let values = readings.map(\.currentUV)
        return (values.max() ?? 0) - (values.min() ?? 0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Data Sources", systemImage: "antenna.radiowaves.left.and.right")
                .font(.headline)

            ForEach(readings, id: \.source) { reading in
                HStack {
                    Text(reading.source)
                        .font(.subheadline)
                    Spacer()
                    Text(String(format: "%.1f", reading.currentUV))
                        .font(.subheadline.monospacedDigit().weight(.medium))
                }
            }

            if readings.count > 1 {
                Divider()
                Label(
                    sourcesAgree
                        ? "Sources agree"
                        : String(format: "Sources differ by %.1f — using average", spread),
                    systemImage: sourcesAgree ? "checkmark.circle.fill" : "exclamationmark.circle.fill"
                )
                .font(.caption)
                .foregroundStyle(sourcesAgree ? Color.green : Color.orange)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}
