import Foundation

struct CalculatorRequest: Encodable {
    let structureType: String   // "ROOF_SLAB" | "WALL"
    let length: Double
    let width: Double
    let height: Double
    let thickness: Double
}

struct CalculatorResponse: Decodable {
    let structureSummary: String?
    let materials: [MaterialLine]
}

struct MaterialLine: Decodable, Identifiable {
    let materialType: String
    let requiredQuantity: Double
    let unit: String
    let matchedItems: [MatchedItem]

    var id: String { materialType }
}

struct MatchedItem: Decodable, Identifiable {
    let itemId: Int
    let name: String
    let price: Decimal
    let unit: String
    let availableQuantity: Int
    let providerName: String?
    let lowestPrice: Bool

    var id: Int { itemId }
}
