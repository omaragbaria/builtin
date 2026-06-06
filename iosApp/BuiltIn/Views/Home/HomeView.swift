import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = HomeViewModel()
    @State private var searchQuery = ""
    @State private var navigateToSearch = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.top, 60)
                    }

                    if let error = viewModel.error {
                        ErrorBanner(message: error)
                    }

                    featuredSection
                    providersSection
                }
                .padding(.vertical)
            }
            .navigationTitle("BuiltIn")
            .toolbar { cartButton }
            .searchable(text: $searchQuery, prompt: "Search products…")
            .onSubmit(of: .search) {
                guard !searchQuery.isEmpty else { return }
                navigateToSearch = true
            }
            .navigationDestination(isPresented: $navigateToSearch) {
                SearchView(initialQuery: searchQuery)
            }
            .task { await viewModel.load() }
        }
    }

    // MARK: - Featured

    @ViewBuilder
    private var featuredSection: some View {
        if !viewModel.featuredItems.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader("Featured Products", destination: ProductsView())

                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                    spacing: 12
                ) {
                    ForEach(viewModel.featuredItems) { item in
                        NavigationLink(destination: ProductDetailView(itemId: item.id)) {
                            ItemCardView(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Providers

    @ViewBuilder
    private var providersSection: some View {
        if !viewModel.providers.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Providers")
                    .font(.title2.bold())
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(viewModel.providers) { provider in
                            NavigationLink(destination: ProviderProductsView(provider: provider)) {
                                ProviderPill(provider: provider)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    // MARK: - Helpers

    private func sectionHeader<D: View>(_ title: String, destination: D) -> some View {
        HStack {
            Text(title).font(.title2.bold())
            Spacer()
            NavigationLink(destination: destination) {
                Text("See All").font(.subheadline).foregroundStyle(.tint)
            }
        }
        .padding(.horizontal)
    }

    private var cartButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            NavigationLink(destination: CartView()) {
                Label("Cart", systemImage: "cart")
                    .overlay(alignment: .topTrailing) {
                        if appState.cartCount > 0 {
                            Text("\(appState.cartCount)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(4)
                                .background(.red, in: Circle())
                                .offset(x: 8, y: -8)
                        }
                    }
            }
        }
    }
}

// MARK: - Provider pill

private struct ProviderPill: View {
    let provider: ProviderDto

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "building.2.fill")
                .font(.title2)
                .foregroundStyle(.tint)
                .frame(width: 52, height: 52)
                .background(Color(.secondarySystemBackground), in: Circle())

            Text(provider.name)
                .font(.caption.weight(.medium))
                .foregroundStyle(.primary)
                .lineLimit(1)
        }
        .frame(width: 72)
    }
}
