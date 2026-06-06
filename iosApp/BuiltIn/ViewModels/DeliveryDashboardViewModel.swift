import Foundation

@MainActor
final class DeliveryDashboardViewModel: ObservableObject {
    @Published var pending: [DeliveryDto] = []
    @Published var mine: [DeliveryDto] = []
    @Published var isLoading = false
    @Published var error: String?

    func load(accountId: Int?) async {
        isLoading = true
        error = nil
        defer { isLoading = false }
        do {
            async let pendingTask: [DeliveryDto] = APIClient.shared.request(.pendingDeliveries)
            if let accountId {
                async let mineTask: [DeliveryDto] = APIClient.shared.request(.deliveriesByAccount(accountId: accountId))
                let (p, m) = try await (pendingTask, mineTask)
                pending = p
                mine = m
            } else {
                pending = try await pendingTask
                mine = []
            }
        } catch {
            self.error = error.localizedDescription
        }
    }

    func accept(deliveryId: Int, accountId: Int) async {
        do {
            try await APIClient.shared.requestVoid(
                .acceptDelivery(id: deliveryId),
                method: .post,
                body: AcceptDeliveryRequest(deliveryAccountId: accountId)
            )
            await load(accountId: accountId)
        } catch {
            self.error = error.localizedDescription
        }
    }

    func updateStage(deliveryId: Int, stage: DeliveryStage, accountId: Int?) async {
        do {
            try await APIClient.shared.requestVoid(
                .updateDeliveryStage(id: deliveryId),
                method: .post,
                body: UpdateStageRequest(stage: stage)
            )
            await load(accountId: accountId)
        } catch {
            self.error = error.localizedDescription
        }
    }

    /// Driver has at least one ACCEPTED or IN_DELIVERY package?
    /// Drives the GPS broadcaster on/off state (M5 driver-side parity).
    var hasActiveDelivery: Bool {
        mine.contains { $0.stage == .accepted || $0.stage == .inDelivery }
    }

    func count(_ stage: DeliveryStage) -> Int {
        mine.filter { $0.stage == stage }.count
    }
}
