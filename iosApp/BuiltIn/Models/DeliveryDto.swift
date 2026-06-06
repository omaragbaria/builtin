import Foundation

struct DeliveryDto: Codable, Identifiable, Equatable {
    let id: Int
    let dealId: Int
    let dealTotal: Decimal
    let dealShippingMethod: String?
    let dealStatus: String?
    let customerName: String?
    let customerEmail: String?
    let stage: DeliveryStage
    let eta: Date?
    let assignedAt: Date?
    let createdAt: Date
    let deliveryAccountId: Int?
    let deliveryAccountName: String?
    let deliveryAccountEmail: String?
    let vehicleType: VehicleType?
    let deliveryAccountType: DeliveryAccountType?
    let driverLatitude: Double?
    let driverLongitude: Double?
}

enum DeliveryStage: String, Codable, CaseIterable {
    case pendingAssignment = "PENDING_ASSIGNMENT"
    case accepted          = "ACCEPTED"
    case inDelivery        = "IN_DELIVERY"
    case arrived           = "ARRIVED"

    var displayLabel: String {
        switch self {
        case .pendingAssignment: return "Pending Assignment"
        case .accepted:          return "Accepted"
        case .inDelivery:        return "In Delivery"
        case .arrived:           return "Arrived"
        }
    }

    /// Customer-facing label used on the order-tracking screen.
    /// Mirrors `tracking.stage.*` in `webApp/.../messages.properties`.
    var customerLabel: String {
        switch self {
        case .pendingAssignment: return "Order Received"
        case .accepted:          return "Accepted by Courier"
        case .inDelivery:        return "Out for Delivery"
        case .arrived:           return "Delivered"
        }
    }

    var customerDescription: String {
        switch self {
        case .pendingAssignment: return "Waiting for a courier to accept"
        case .accepted:          return "Courier has accepted the package"
        case .inDelivery:        return "Package is on its way"
        case .arrived:           return "Package has been delivered"
        }
    }

    var sortOrder: Int {
        switch self {
        case .pendingAssignment: return 0
        case .accepted:          return 1
        case .inDelivery:        return 2
        case .arrived:           return 3
        }
    }

    var next: DeliveryStage? {
        switch self {
        case .pendingAssignment: return .accepted
        case .accepted:          return .inDelivery
        case .inDelivery:        return .arrived
        case .arrived:           return nil
        }
    }
}

struct DeliveryAccountDto: Codable, Identifiable, Equatable {
    let id: Int
    let firstName: String
    let lastName: String
    let email: String
    let phone: String?
    let deliveryAccountType: DeliveryAccountType
    let vehicleType: VehicleType?
    let drivers: [DriverDto]?

    var displayName: String { "\(firstName) \(lastName)" }
}

struct DriverDto: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
    let phone: String?
}

enum DeliveryAccountType: String, Codable, CaseIterable {
    case individual = "INDIVIDUAL"
    case company    = "COMPANY"
}

enum VehicleType: String, Codable, CaseIterable {
    case bike          = "BIKE"
    case motorbike     = "MOTORBIKE"
    case car           = "CAR"
    case truck         = "TRUCK"
    case largeTruck    = "LARGE_TRUCK"
    case trailerTruck  = "TRAILER_TRUCK"
    case fridgeTruck   = "FRIDGE_TRUCK"
    case mixedTruck    = "MIXED_TRUCK"
    case truckWithWinch = "TRUCK_WITH_WINCH"

    var displayLabel: String {
        switch self {
        case .bike:           return "Bike"
        case .motorbike:      return "Motorbike"
        case .car:            return "Car"
        case .truck:          return "Truck"
        case .largeTruck:     return "Large Truck"
        case .trailerTruck:   return "Trailer Truck"
        case .fridgeTruck:    return "Fridge Truck"
        case .mixedTruck:     return "Mixed Truck"
        case .truckWithWinch: return "Truck with Winch"
        }
    }
}

// MARK: - Requests

struct AcceptDeliveryRequest: Encodable {
    let deliveryAccountId: Int
}

struct UpdateStageRequest: Encodable {
    let stage: DeliveryStage
}

struct UpdateEtaRequest: Encodable {
    let eta: Date
}

struct UpdateLocationRequest: Encodable {
    let latitude: Double
    let longitude: Double
}

struct CreateDeliveryAccountRequest: Encodable {
    let firstName: String
    let lastName: String
    let email: String
    let phone: String
    let deliveryAccountType: DeliveryAccountType
    let vehicleType: VehicleType
    let drivers: [DriverInput]

    struct DriverInput: Encodable {
        let name: String
        let phone: String
    }
}
