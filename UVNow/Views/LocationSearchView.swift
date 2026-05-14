import SwiftUI

struct LocationSearchView: View {
    @Bindable var viewModel: UVViewModel

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("City or location…", text: $viewModel.locationInput)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .onSubmit {
                        Task { await viewModel.searchLocation() }
                    }
                if !viewModel.locationInput.isEmpty {
                    Button {
                        viewModel.locationInput = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(12)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))

            HStack(spacing: 12) {
                Button {
                    Task { await viewModel.searchLocation() }
                } label: {
                    Label("Search", systemImage: "magnifyingglass")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.locationInput.trimmingCharacters(in: .whitespaces).isEmpty
                          || viewModel.isLoading)

                Button {
                    Task { await viewModel.useCurrentLocation() }
                } label: {
                    Label("My Location", systemImage: "location.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.isLoading)
            }
        }
    }
}
