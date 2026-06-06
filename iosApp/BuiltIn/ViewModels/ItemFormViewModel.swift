import Foundation

@MainActor
final class ItemFormViewModel: ObservableObject {
    /// Field state
    @Published var name: String = ""
    @Published var type: String = ""
    @Published var category: ItemCategory? = nil
    @Published var serialNumber: String = ""
    @Published var price: String = "0"
    @Published var quantity: String = "0"
    @Published var unit: ItemUnit = .unit
    @Published var prices: [PriceRow] = []

    /// UI state
    @Published var isSaving = false
    @Published var error: String?
    @Published var saveSuccess = false

    /// Mode — nil means "create new", non-nil means "edit existing".
    let existing: ItemDto?
    let providerId: Int?

    init(existing: ItemDto?, providerId: Int?) {
        self.existing = existing
        self.providerId = providerId
        if let item = existing {
            name = item.name
            type = item.type ?? ""
            category = item.category
            serialNumber = item.serialNumber ?? ""
            price = "\(item.price)"
            quantity = "\(item.quantity)"
            unit = item.unit
            prices = (item.prices ?? []).map { p in
                PriceRow(method: p.shippingMethod,
                         amount: "\(p.amount)",
                         deliveryTime: p.deliveryTime ?? "")
            }
        }
    }

    struct PriceRow: Identifiable {
        let id = UUID()
        var method: ShippingMethod = .standard
        var amount: String = ""
        var deliveryTime: String = ""
    }

    func addPriceRow() {
        prices.append(PriceRow())
    }

    func removePriceRow(id: UUID) {
        prices.removeAll { $0.id == id }
    }

    func save() async {
        isSaving = true
        error = nil
        defer { isSaving = false }

        let request = CreateItemRequest(
            name: name,
            type: type.isEmpty ? nil : type,
            category: category?.rawValue,
            serialNumber: serialNumber.isEmpty ? nil : serialNumber,
            price: Decimal(string: price) ?? 0,
            quantity: Int(quantity) ?? 0,
            unit: unit.rawValue,
            provider: providerId.map { .init(id: $0) }
        )

        do {
            let saved: ItemDto
            if let existing {
                saved = try await APIClient.shared.request(
                    .updateItem(id: existing.id), method: .put, body: request)
            } else {
                saved = try await APIClient.shared.request(
                    .createItem, method: .post, body: request)
            }
            try await submitPrices(itemId: saved.id)
            saveSuccess = true
        } catch {
            self.error = error.localizedDescription
        }
    }

    private func submitPrices(itemId: Int) async throws {
        let payload: [ItemPriceRequest] = prices.compactMap { row in
            guard let amount = Decimal(string: row.amount), amount > 0 else { return nil }
            return ItemPriceRequest(
                amount: amount,
                currency: "ILS",
                shippingMethod: row.method,
                deliveryTime: row.deliveryTime.isEmpty ? nil : row.deliveryTime
            )
        }
        guard !payload.isEmpty else { return }
        try await APIClient.shared.requestVoid(
            .itemPrices(id: itemId),
            method: .put,
            body: payload
        )
    }
}
