import SwiftUI

struct UVGaugeView: View {
    let uvIndex: Double
    let level: UVLevel
    let locationName: String

    private static let arcStart = 0.375
    private static let arcEnd   = 1.125
    private static let arcSpan  = arcEnd - arcStart  // 0.75 of full circle

    private var fillFraction: Double {
        min(uvIndex / 11.0, 1.0) * Self.arcSpan
    }

    var body: some View {
        VStack(spacing: 16) {
            Text(locationName)
                .font(.title2.weight(.semibold))
                .multilineTextAlignment(.center)

            ZStack {
                // Track
                Circle()
                    .trim(from: Self.arcStart, to: Self.arcEnd)
                    .stroke(Color.secondary.opacity(0.15),
                            style: StrokeStyle(lineWidth: 22, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                // Colored fill
                Circle()
                    .trim(from: Self.arcStart, to: Self.arcStart + fillFraction)
                    .stroke(
                        AngularGradient(
                            colors: [
                                Color(red: 0.18, green: 0.72, blue: 0.18),
                                Color(red: 1.0,  green: 0.84, blue: 0.0),
                                Color(red: 1.0,  green: 0.55, blue: 0.0),
                                Color(red: 0.9,  green: 0.1,  blue: 0.1),
                                Color(red: 0.56, green: 0.0,  blue: 0.56),
                            ],
                            center: .center,
                            startAngle: .degrees(Self.arcStart * 360),
                            endAngle:   .degrees(Self.arcEnd   * 360)
                        ),
                        style: StrokeStyle(lineWidth: 22, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(duration: 0.6), value: uvIndex)

                // Center labels
                VStack(spacing: 2) {
                    Text(String(format: "%.1f", uvIndex))
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                    Text(level.rawValue)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                }

                // Min / max labels at arc ends
                GeometryReader { geo in
                    let r = geo.size.width / 2 - 6
                    let cx = geo.size.width  / 2
                    let cy = geo.size.height / 2
                    let startAngle = (Self.arcStart - 0.25) * 2 * .pi
                    let endAngle   = (Self.arcEnd   - 0.25) * 2 * .pi

                    Text("0")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .position(
                            x: cx + r * cos(startAngle),
                            y: cy + r * sin(startAngle)
                        )

                    Text("11+")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .position(
                            x: cx + r * cos(endAngle),
                            y: cy + r * sin(endAngle)
                        )
                }
            }
            .frame(width: 200, height: 200)

            Label(level.rawValue, systemImage: level.symbol)
                .font(.title3.weight(.medium))
                .foregroundStyle(level.color)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(level.color.opacity(0.15), in: Capsule())
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}

struct TodayMaxCard: View {
    let uvMax: Double
    let level: UVLevel

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Today's Peak")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(String(format: "%.1f", uvMax))
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                    Text("UV max")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Image(systemName: level.symbol)
                .font(.system(size: 40))
                .foregroundStyle(level.color)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}
