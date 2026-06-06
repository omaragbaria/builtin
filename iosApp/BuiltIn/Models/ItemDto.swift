import Foundation

struct ItemDto: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
    let nameAr: String?
    let nameHe: String?
    let nameRu: String?
    let nameZh: String?
    let type: String?
    let category: ItemCategory?
    let serialNumber: String?
    let price: Decimal
    let quantity: Int
    let unit: ItemUnit
    let provider: ProviderDto?
    let photos: [PhotoDto]?
    let shippingTime: String?
    let locations: [ProviderLocationDto]?
    let prices: [ItemPriceDto]?

    func localizedName(lang: String) -> String {
        let translated: String? = switch lang {
        case "ar": nameAr
        case "he": nameHe
        case "ru": nameRu
        case "zh": nameZh
        default:   nil
        }
        return translated?.isEmpty == false ? translated! : name
    }
}

struct ItemPriceDto: Codable, Identifiable, Equatable {
    let id: Int
    let amount: Decimal
    let currency: String
    let shippingMethod: ShippingMethod
    let deliveryTime: String?
}

struct PhotoDto: Codable, Identifiable, Equatable {
    let id: Int
    let fileName: String
    let contentType: String?

    var photoURL: URL {
        Endpoint.photo(filename: fileName).url
    }
}

enum ItemUnit: String, Codable, CaseIterable {
    case unit        = "UNIT"
    case kg          = "KG"
    case gram        = "GRAM"
    case liter       = "LITER"
    case milliliter  = "MILLILITER"
    case meter       = "METER"
    case centimeter  = "CENTIMETER"
    case millimeter  = "MILLIMETER"
    case squareMeter = "SQUARE_METER"
    case cubicMeter  = "CUBIC_METER"
    case pack        = "PACK"
    case box         = "BOX"
    case dozen       = "DOZEN"

    var displayLabel: String {
        switch self {
        case .unit:        return "Unit"
        case .kg:          return "kg"
        case .gram:        return "g"
        case .liter:       return "L"
        case .milliliter:  return "mL"
        case .meter:       return "m"
        case .centimeter:  return "cm"
        case .millimeter:  return "mm"
        case .squareMeter: return "m²"
        case .cubicMeter:  return "m³"
        case .pack:        return "Pack"
        case .box:         return "Box"
        case .dozen:       return "Dozen"
        }
    }
}

enum ItemCategory: String, Codable, CaseIterable {
    case sealingAndAdhesives   = "SEALING_AND_ADHESIVES"
    case paintsSprays          = "PAINTS_SPRAYS_CLEANING"
    case cuttingAndGrinding    = "CUTTING_AND_GRINDING"
    case polishingAndSanding   = "POLISHING_AND_SANDING"
    case ceramicsAndTiling     = "CERAMICS_AND_TILING"
    case plasterboard          = "PLASTERBOARD"
    case cementAndAdhesives    = "CEMENT_AND_ADHESIVES"
    case ironAndMetal          = "IRON_AND_METAL"

    var displayLabel: String {
        switch self {
        case .sealingAndAdhesives:  return "Sealing & Adhesives"
        case .paintsSprays:         return "Paints, Sprays & Cleaning"
        case .cuttingAndGrinding:   return "Cutting & Grinding"
        case .polishingAndSanding:  return "Polishing & Sanding"
        case .ceramicsAndTiling:    return "Ceramics & Tiling"
        case .plasterboard:         return "Plasterboard"
        case .cementAndAdhesives:   return "Cement & Adhesives"
        case .ironAndMetal:         return "Iron & Metal"
        }
    }
}

enum ShippingMethod: String, Codable, CaseIterable {
    case selfPickup = "SELF_PICKUP"
    case immediate  = "IMMEDIATE"
    case fast       = "FAST"
    case standard   = "STANDARD"

    var displayLabel: String {
        switch self {
        case .selfPickup: return "Self Pickup"
        case .immediate:  return "Immediate (within 24h)"
        case .fast:       return "Fast (2–5 business days)"
        case .standard:   return "Standard (up to 14 days)"
        }
    }
}
