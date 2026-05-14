import SwiftUI

struct SkinTonePickerView: View {
    @Bindable var viewModel: UVViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your Skin Type")
                .font(.headline)

            HStack(spacing: 12) {
                ForEach(FitzpatrickType.allCases, id: \.rawValue) { type in
                    let isSelected = viewModel.skinTypeRaw == type.rawValue
                    Circle()
                        .fill(type.swatchColor)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Circle()
                                .strokeBorder(isSelected ? Color.primary : Color.clear, lineWidth: 3)
                        )
                        .shadow(color: .black.opacity(0.15), radius: 2, y: 1)
                        .onTapGesture { viewModel.skinTypeRaw = type.rawValue }
                        .animation(.easeInOut(duration: 0.15), value: isSelected)
                }
            }

            Text(viewModel.skinType.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .animation(.easeInOut, value: viewModel.skinTypeRaw)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}
