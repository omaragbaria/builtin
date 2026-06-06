import Foundation

/// Request body for `POST /api/items` and `PUT /api/items/{id}`.
/// Mirrors `webApp/.../CreateItemRequest.java`.
struct CreateItemRequest: Encodable {
    let name: String
    let type: String?
    let category: String?      // enum-name or nil
    let serialNumber: String?
    let price: Decimal
    let quantity: Int
    let unit: String           // enum-name
    let provider: ProviderRef?

    struct ProviderRef: Encodable { let id: Int }
}

/// Request body for `PUT /api/items/{id}/prices` — array of these.
/// Mirrors `BE/.../ItemPriceRequest.java`.
struct ItemPriceRequest: Encodable {
    let amount: Decimal
    let currency: String
    let shippingMethod: ShippingMethod
    let deliveryTime: String?
}
