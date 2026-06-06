import Foundation

@MainActor
final class ProductDetailViewModel: ObservableObject {
    @Published var item: ItemDto?
    @Published var relatedItems: [ItemDto] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var addedToCart = false

    private let itemId: Int

    init(itemId: Int) {
        self.itemId = itemId
    }

    func load() async {
        isLoading = true
        error = nil
        defer { isLoading = false }
        do {
            let loaded: ItemDto = try await APIClient.shared.request(.item(id: itemId))
            item = loaded

            if let providerId = loaded.provider?.id {
                let all: [ItemDto] = try await APIClient.shared.request(.providerItems(providerId: providerId))
                relatedItems = all.filter { $0.id != itemId }.prefix(4).map { $0 }
            }
        } catch {
            self.error = error.localizedDescription
        }
    }

    func addToCart(appState: AppState, quantity: Int) {
        guard let item else { return }
        appState.addToCart(item, quantity: quantity)
        addedToCart = true

        Task {
            try? await Task.sleep(for: .seconds(2))
            addedToCart = false
        }
    }
}
