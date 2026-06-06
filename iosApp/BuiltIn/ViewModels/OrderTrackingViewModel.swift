import Foundation

@MainActor
final class OrderTrackingViewModel: ObservableObject {
    @Published var delivery: DeliveryDto?
    @Published var isLoading = false
    @Published var error: String?
    @Published var dealIdInput = ""

    private var pollingTask: Task<Void, Never>?

    func track(dealId: Int) async {
        isLoading = true
        error = nil
        pollingTask?.cancel()
        defer { isLoading = false }
        do {
            delivery = try await APIClient.shared.request(.deliveryByDeal(dealId: dealId))
            startPolling(dealId: dealId)
        } catch APIError.notFound {
            delivery = nil
            error = "No delivery found for order #\(dealId)."
        } catch {
            self.error = error.localizedDescription
        }
    }

    func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
    }

    private func startPolling(dealId: Int) {
        pollingTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(10))
                guard !Task.isCancelled, let self else { break }
                if let updated: DeliveryDto = try? await APIClient.shared.request(.deliveryByDeal(dealId: dealId)) {
                    self.delivery = updated
                }
                if self.delivery?.stage == .arrived { break }
            }
        }
    }
}
