import Foundation

@MainActor
final class CartViewModel: ObservableObject {
    @Published var isCheckingOut = false
    @Published var checkoutError: String?
    @Published var checkoutSuccess = false
    @Published var completedDealId: Int?

    func checkout(
        appState: AppState,
        method: ShippingMethod,
        deliveryLat: Double?,
        deliveryLng: Double?
    ) async {
        guard !appState.cart.isEmpty else { return }
        isCheckingOut = true
        checkoutError = nil
        defer { isCheckingOut = false }

        let items = appState.cart.map {
            CheckoutRequest.CheckoutItem(itemId: $0.itemId, quantity: $0.quantity)
        }
        let request = CheckoutRequest(
            userId: appState.currentUser?.id ?? 0,
            shippingMethod: method,
            items: items,
            deliveryLatitude: deliveryLat,
            deliveryLongitude: deliveryLng
        )

        do {
            let deal: DealDto = try await APIClient.shared.request(.checkout, method: .post, body: request)
            completedDealId = deal.id
            appState.lastDealId = deal.id
            appState.clearCart()
            checkoutSuccess = true
        } catch APIError.noDriversAvailable {
            checkoutError = "No drivers available for immediate delivery. Please choose another shipping method."
        } catch {
            checkoutError = error.localizedDescription
        }
    }
}
