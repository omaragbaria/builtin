import SwiftUI

struct ProviderLocationsView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = ProviderLocationsViewModel()
    @State private var showAdd = false

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.locations.isEmpty {
                ProgressView()
            } else if let error = viewModel.error, viewModel.locations.isEmpty {
                ErrorBanner(message: error).padding()
            } else if viewModel.locations.isEmpty {
                ContentUnavailableView {
                    Label(L10n.t("provider.locations"), systemImage: "mappin.and.ellipse")
                } description: {
                    Text(L10n.t("provider.add_location"))
                }
            } else {
                List {
                    ForEach(viewModel.locations) { loc in
                        LocationRow(location: loc)
                    }
                    .onDelete(perform: deleteRows)
                }
            }
        }
        .navigationTitle(Text(L10n.t("provider.locations")))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAdd = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .task { await load() }
        .refreshable { await load() }
        .sheet(isPresented: $showAdd) {
            NavigationStack {
                LocationFormView { request in
                    guard let pid = appState.currentUser?.providerId else { return false }
                    return await viewModel.add(providerId: pid, request: request)
                }
            }
        }
    }

    private func load() async {
        guard let pid = appState.currentUser?.providerId else { return }
        await viewModel.load(providerId: pid)
    }

    private func deleteRows(at offsets: IndexSet) {
        guard let pid = appState.currentUser?.providerId else { return }
        let toDelete = offsets.map { viewModel.locations[$0].id }
        Task {
            for id in toDelete {
                await viewModel.delete(providerId: pid, locationId: id)
            }
        }
    }
}

private struct LocationRow: View {
    let location: ProviderLocationDto

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(location.label ?? "—").font(.subheadline.weight(.semibold))
            HStack(spacing: 6) {
                if let city = location.city, !city.isEmpty {
                    Text(city)
                }
                if let country = location.country, !country.isEmpty {
                    Text("·")
                    Text(country)
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            if let lat = location.latitude, let lng = location.longitude {
                Text(String(format: "%.4f, %.4f", lat, lng))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct LocationFormView: View {
    var onSave: (CreateProviderLocationRequest) async -> Bool
    @Environment(\.dismiss) private var dismiss

    @State private var label = ""
    @State private var country = ""
    @State private var city = ""
    @State private var zipCode = ""
    @State private var latitude = ""
    @State private var longitude = ""
    @State private var isSaving = false

    var body: some View {
        Form {
            Section {
                TextField("Label", text: $label)
                TextField("City", text: $city)
                TextField("Country", text: $country)
                TextField("ZIP / postal code", text: $zipCode)
            }
            Section("Coordinates") {
                TextField("Latitude", text: $latitude).keyboardType(.numbersAndPunctuation)
                TextField("Longitude", text: $longitude).keyboardType(.numbersAndPunctuation)
            }
        }
        .navigationTitle(Text(L10n.t("provider.add_location")))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(L10n.t("common.cancel")) { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    Task { await save() }
                } label: {
                    if isSaving { ProgressView() }
                    else { Text(L10n.t("common.save")).fontWeight(.semibold) }
                }
                .disabled(isSaving || label.isEmpty)
            }
        }
    }

    private func save() async {
        isSaving = true
        defer { isSaving = false }
        let request = CreateProviderLocationRequest(
            label: label,
            country: country,
            city: city,
            zipCode: zipCode,
            latitude: Double(latitude) ?? 0,
            longitude: Double(longitude) ?? 0
        )
        if await onSave(request) {
            dismiss()
        }
    }
}
