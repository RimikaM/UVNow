import MapKit
import SwiftUI

struct LocationSearchView: View {
    @Bindable var viewModel: UVViewModel
    @State private var completer = LocationSearchCompleter()
    @State private var isFocused = false

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("City, zip code, or location…", text: $viewModel.locationInput)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .onSubmit {
                            isFocused = false
                            completer.suggestions = []
                            Task { await viewModel.searchLocation() }
                        }
                        .onChange(of: viewModel.locationInput) { _, newValue in
                            completer.query = newValue
                            isFocused = !newValue.isEmpty
                        }
                    if !viewModel.locationInput.isEmpty {
                        Button {
                            viewModel.locationInput = ""
                            completer.suggestions = []
                            isFocused = false
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
                        isFocused = false
                        completer.suggestions = []
                        Task { await viewModel.searchLocation() }
                    } label: {
                        Label("Search", systemImage: "magnifyingglass")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.locationInput.trimmingCharacters(in: .whitespaces).isEmpty
                              || viewModel.isLoading)

                    Button {
                        isFocused = false
                        completer.suggestions = []
                        Task { await viewModel.useCurrentLocation() }
                    } label: {
                        Label("My Location", systemImage: "location.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(viewModel.isLoading)
                }
            }

            if isFocused && !completer.suggestions.isEmpty {
                VStack(spacing: 0) {
                    ForEach(completer.suggestions.prefix(5), id: \.self) { suggestion in
                        Button {
                            let title = suggestion.title
                            let subtitle = suggestion.subtitle
                            viewModel.locationInput = subtitle.isEmpty ? title : "\(title), \(subtitle)"
                            isFocused = false
                            completer.suggestions = []
                            Task { await viewModel.searchLocation() }
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(suggestion.title)
                                        .foregroundStyle(.primary)
                                    if !suggestion.subtitle.isEmpty {
                                        Text(suggestion.subtitle)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                        }
                        .buttonStyle(.plain)
                        if suggestion !== completer.suggestions.prefix(5).last {
                            Divider().padding(.leading, 12)
                        }
                    }
                }
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                .padding(.top, 4)
            }
        }
    }
}
