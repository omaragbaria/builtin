import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var featuredItems: [ItemDto] = []
    @Published var providers: [ProviderDto] = []
    @Published var isLoading = false
    @Published var error: String?

    func load() async {
        guard featuredItems.isEmpty else { return }
        isLoading = true
        error = nil
        defer { isLoading = false }
        do {
            async let itemsFetch: [ItemDto] = APIClient.shared.request(.items)
            async let providersFetch: [ProviderDto] = APIClient.shared.request(.providers)
            let (all, allProviders) = try await (itemsFetch, providersFetch)
            featuredItems = Array(all.prefix(8))
            providers = allProviders
        } catch {
            self.error = error.localizedDescription
        }
    }
}
