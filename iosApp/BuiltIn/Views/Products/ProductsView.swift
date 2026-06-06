import SwiftUI

struct ProductsView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = ProductsViewModel()
    @State private var showFilter = false

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.filteredItems.isEmpty {
                ContentUnavailableView("No Products", systemImage: "shippingbox", description: Text("Try adjusting your filters."))
            } else if viewModel.viewMode == .card {
                gridView
            } else {
                listView
            }
        }
        .navigationTitle("Products")
        .toolbar { toolbarItems }
        .sheet(isPresented: $showFilter) {
            FilterSheet(viewModel: viewModel)
        }
        .task { await viewModel.load() }
        .overlay(alignment: .top) {
            if let error = viewModel.error { ErrorBanner(message: error) }
        }
    }

    // MARK: - Grid

    private var gridView: some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                spacing: 12
            ) {
                ForEach(viewModel.filteredItems) { item in
                    NavigationLink(destination: ProductDetailView(itemId: item.id)) {
                        ItemCardView(item: item)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
    }

    // MARK: - List

    private var listView: some View {
        List(viewModel.filteredItems) { item in
            NavigationLink(destination: ProductDetailView(itemId: item.id)) {
                ItemRowView(item: item)
            }
        }
        .listStyle(.plain)
    }

    // MARK: - Toolbar

    private var toolbarItems: some ToolbarContent {
        Group {
            ToolbarItem(placement: .topBarLeading) {
                Text("\(viewModel.filteredItems.count) items")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 12) {
                    Button {
                        viewModel.viewMode = viewModel.viewMode == .card ? .list : .card
                    } label: {
                        Image(systemName: viewModel.viewMode == .card ? "list.bullet" : "square.grid.2x2")
                    }
                    Button {
                        showFilter = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle\(viewModel.selectedCategory != nil ? ".fill" : "")")
                    }
                }
            }
        }
    }
}

// MARK: - Filter Sheet

struct FilterSheet: View {
    @ObservedObject var viewModel: ProductsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Category") {
                    Button("All") {
                        viewModel.selectedCategory = nil
                    }
                    .foregroundStyle(viewModel.selectedCategory == nil ? Color.accentColor : Color.primary)

                    ForEach(viewModel.availableCategories, id: \.self) { cat in
                        Button(cat.displayLabel) {
                            viewModel.selectedCategory = cat
                        }
                        .foregroundStyle(viewModel.selectedCategory == cat ? Color.accentColor : Color.primary)
                    }
                }

                Section("Max Price: \(viewModel.maxPrice.currencyFormatted())") {
                    Slider(
                        value: Binding(
                            get: { Double(truncating: viewModel.maxPrice as NSDecimalNumber) },
                            set: { viewModel.maxPrice = Decimal($0) }
                        ),
                        in: 0...Double(truncating: viewModel.globalMaxPrice as NSDecimalNumber),
                        step: 10
                    )
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Reset") {
                        viewModel.selectedCategory = nil
                        viewModel.maxPrice = viewModel.globalMaxPrice
                    }
                    .foregroundStyle(.red)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
