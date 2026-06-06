import Foundation

struct DealDto: Codable, Identifiable, Equatable {
    let id: Int
    let totalPrice: Decimal
    let status: DealStatus
    let shippingMethod: ShippingMethod?
    let dealDate: Date?
}

enum DealStatus: String, Codable, CaseIterable {
    case complete         = "COMPLETE"
    case processing       = "PROCESSING"
    case pendingApproval  = "PENDING_APPROVAL"
    case canceled         = "CANCELED"
    case delivery         = "DELIVERY"

    var displayLabel: String {
        switch self {
        case .complete:        return "Complete"
        case .processing:      return "Processing"
        case .pendingApproval: return "Pending Approval"
        case .canceled:        return "Canceled"
        case .delivery:        return "Out for Delivery"
        }
    }
}
