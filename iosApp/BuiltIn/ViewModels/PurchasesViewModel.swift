import Foundation

@MainActor
final class PurchasesViewModel: ObservableObject {
    @Published var deals: [DealDto] = []
    @Published var isLoading = false
    @Published var error: String?

    func load(userId: Int?) async {
        guard let userId, userId > 0 else {
            deals = []
            return
        }
        isLoading = true
        error = nil
        defer { isLoading = false }
        do {
            let result: [DealDto] = try await APIClient.shared.request(.userDeals(userId: userId))
            // Newest first.
            deals = result.sorted { ($0.dealDate ?? .distantPast) > ($1.dealDate ?? .distantPast) }
        } catch {
            self.error = error.localizedDescription
        }
    }
}
