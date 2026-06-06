import Foundation
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published var currentUser: UserDto?
    @Published var cart: [CartItemDto] = []
    @Published var lastDealId: Int?
    @Published var selectedShippingMethod: ShippingMethod = .standard

    init() {
        currentUser = UserSession.load()
    }

    // MARK: - Auth

    var isLoggedIn: Bool { currentUser != nil }

    func login(user: UserDto) {
        currentUser = user
    }

    func logout() {
        currentUser = nil
        cart = []
        lastDealId = nil
        UserSession.clear()
    }

    // MARK: - Cart

    func addToCart(_ item: ItemDto, quantity: Int = 1) {
        if let index = cart.firstIndex(where: { $0.itemId == item.id }) {
            cart[index].quantity += quantity
        } else {
            cart.append(CartItemDto(
                itemId: item.id,
                name: item.name,
                price: item.price,
                unit: item.unit,
                quantity: quantity,
                providerName: item.provider?.name,
                shippingTime: item.shippingTime,
                prices: item.prices
            ))
        }
    }

    func updateQuantity(itemId: Int, quantity: Int) {
        if quantity <= 0 {
            removeFromCart(itemId: itemId)
        } else if let index = cart.firstIndex(where: { $0.itemId == itemId }) {
            cart[index].quantity = quantity
        }
    }

    func removeFromCart(itemId: Int) {
        cart.removeAll { $0.itemId == itemId }
    }

    func clearCart() {
        cart = []
    }

    var cartTotal: Decimal {
        cart.reduce(Decimal.zero) { $0 + $1.subtotal }
    }

    var cartCount: Int {
        cart.reduce(0) { $0 + $1.quantity }
    }

    // MARK: - Bulk add (from Calculator / Agent)

    func addItemIds(_ ids: [Int], allItems: [ItemDto]) {
        for id in ids {
            if let item = allItems.first(where: { $0.id == id }) {
                addToCart(item, quantity: 1)
            }
        }
    }
}
