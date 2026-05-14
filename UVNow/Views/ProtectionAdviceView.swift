import SwiftUI

struct ProtectionAdviceView: View {
    let level: UVLevel
    let skinType: FitzpatrickType

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Protection Advice")
                .font(.headline)

            // Personalized SPF row
            HStack(spacing: 12) {
                Image(systemName: "drop.fill")
                    .foregroundStyle(level.color)
                    .frame(width: 24)
                if let spf = skinType.recommendedSPF(for: level) {
                    Text("\(spf) recommended for \(skinType.label)")
                        .font(.subheadline)
                } else {
                    Text("No sunscreen needed for \(skinType.label) at this UV level")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            // Behavioral tips (hat, shade, etc.) — SPF row excluded
            ForEach(level.behavioralTips, id: \.text) { tip in
                HStack(spacing: 12) {
                    Image(systemName: tip.icon)
                        .foregroundStyle(level.color)
                        .frame(width: 24)
                    Text(tip.text)
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}
