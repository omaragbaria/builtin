import Foundation

@MainActor
final class AdminDeliveriesViewModel: ObservableObject {
    @Published var all: [DeliveryDto] = []
    @Published var filter: DeliveryStage? = nil   // nil = "all"
    @Published var isLoading = false
    @Published var error: String?

    var filtered: [DeliveryDto] {
        guard let f = filter else { return all }
        return all.filter { $0.stage == f }
    }

    func count(_ stage: DeliveryStage) -> Int {
        all.filter { $0.stage == stage }.count
    }

    func load() async {
        isLoading = true
        error = nil
        defer { isLoading = false }
        do {
            all = try await APIClient.shared.request(.deliveries)
        } catch {
            self.error = error.localizedDescription
        }
    }
}
