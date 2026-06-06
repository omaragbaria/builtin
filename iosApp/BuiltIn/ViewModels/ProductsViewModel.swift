import Foundation

@MainActor
final class ProductsViewModel: ObservableObject {
    @Published var allItems: [ItemDto] = []
    @Published var isLoading = false
    @Published var error: String?

    // Filters (applied client-side — BE has no query params)
    @Published var selectedCategory: ItemCategory? = nil
    @Published var maxPrice: Decimal = 99_999
    @Published var viewMode: ViewMode = .card

    enum ViewMode { case card, list }

    var globalMaxPrice: Decimal {
        allItems.map(\.price).max() ?? 99_999
    }

    var filteredItems: [ItemDto] {
        allItems.filter { item in
            let catOK = selectedCategory == nil || item.category == selectedCategory
            let priceOK = item.price <= maxPrice
            return catOK && priceOK
        }
    }

    var availableCategories: [ItemCategory] {
        Array(Set(allItems.compactMap(\.category))).sorted { $0.displayLabel < $1.displayLabel }
    }

    func load() async {
        guard allItems.isEmpty else { return }
        isLoading = true
        error = nil
        defer { isLoading = false }
        do {
            allItems = try await APIClient.shared.request(.items)
            maxPrice = globalMaxPrice
        } catch {
            self.error = error.localizedDescription
        }
    }
}
