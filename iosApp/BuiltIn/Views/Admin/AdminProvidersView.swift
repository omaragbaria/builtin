import SwiftUI

struct AdminProvidersView: View {
    @StateObject private var viewModel = AdminProvidersViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.providers.isEmpty {
                ProgressView()
            } else if let error = viewModel.error, viewModel.providers.isEmpty {
                ErrorBanner(message: error).padding()
            } else if viewModel.providers.isEmpty {
                ContentUnavailableView(
                    "Providers",
                    systemImage: "building.2",
                    description: Text("No providers found.")
                )
            } else {
                List(viewModel.providers) { p in
                    NavigationLink {
                        AdminProviderDetailView(provider: p)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(p.name).font(.subheadline.weight(.semibold))
                            Text(p.email).font(.caption).foregroundStyle(.secondary)
                            HStack(spacing: 12) {
                                Label("\(p.items?.count ?? 0)", systemImage: "shippingbox")
                                    .font(.caption2)
                                Label("\(p.locations?.count ?? 0)", systemImage: "mappin.and.ellipse")
                                    .font(.caption2)
                            }
                            .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 2)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Providers")
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }
}

private struct AdminProviderDetailView: View {
    let provider: ProviderDto

    var body: some View {
        List {
            Section(L10n.t("provider.locations")) {
                if let locs = provider.locations, !locs.isEmpty {
                    ForEach(locs) { loc in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(loc.label ?? "—").font(.subheadline)
                            if let city = loc.city, !city.isEmpty {
                                Text(city).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                } else {
                    Text("—").foregroundStyle(.secondary)
                }
            }
            Section(L10n.t("provider.items")) {
                if let items = provider.items, !items.isEmpty {
                    ForEach(items) { item in
                        ItemRowView(item: item)
                    }
                } else {
                    Text("—").foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle(provider.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
