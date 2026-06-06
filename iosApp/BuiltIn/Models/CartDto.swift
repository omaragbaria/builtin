import Foundation

struct CartItemDto: Codable, Identifiable, Equatable {
    let itemId: Int
    var name: String
    var price: Decimal
    var unit: ItemUnit
    var quantity: Int
    var providerName: String?
    var shippingTime: String?
    var prices: [ItemPriceDto]?

    var id: Int { itemId }

    var subtotal: Decimal { price * Decimal(quantity) }

    func price(for method: ShippingMethod) -> Decimal? {
        prices?.first(where: { $0.shippingMethod == method })?.amount
    }

    /// Per-method price with fallback to the base price.
    /// Mirrors `BE/.../util/Pricing.java::effectivePrice` so cart totals match the BE.
    func effectivePrice(for method: ShippingMethod) -> Decimal {
        price(for: method) ?? price
    }

    func effectiveSubtotal(for method: ShippingMethod) -> Decimal {
        effectivePrice(for: method) * Decimal(quantity)
    }

    func deliveryTime(for method: ShippingMethod) -> String? {
        prices?.first(where: { $0.shippingMethod == method })?.deliveryTime
    }
}

struct CheckoutRequest: Encodable {
    let userId: Int
    let shippingMethod: ShippingMethod
    let items: [CheckoutItem]
    let deliveryLatitude: Double?
    let deliveryLongitude: Double?

    struct CheckoutItem: Encodable {
        let itemId: Int
        let quantity: Int
    }
}
