import Foundation

@MainActor
final class ProviderItemsViewModel: ObservableObject {
    @Published var items: [ItemDto] = []
    @Published var isLoading = false
    @Published var error: String?

    func load(providerId: Int) async {
        isLoading = true
        error = nil
        defer { isLoading = false }
        do {
            items = try await APIClient.shared.request(.providerItems(providerId: providerId))
        } catch {
            self.error = error.localizedDescription
        }
    }
}
