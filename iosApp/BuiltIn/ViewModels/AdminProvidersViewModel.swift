import Foundation

@MainActor
final class AdminProvidersViewModel: ObservableObject {
    @Published var providers: [ProviderDto] = []
    @Published var isLoading = false
    @Published var error: String?

    func load() async {
        isLoading = true
        error = nil
        defer { isLoading = false }
        do {
            providers = try await APIClient.shared.request(.providers)
        } catch {
            self.error = error.localizedDescription
        }
    }
}
