import Foundation

struct ProviderDto: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
    let location: String?
    let phone: String?
    let email: String
    let items: [ItemDto]?
    let locations: [ProviderLocationDto]?
}

struct ProviderLocationDto: Codable, Identifiable, Equatable {
    let id: Int
    let label: String?
    let country: String?
    let city: String?
    let zipCode: String?
    let latitude: Double?
    let longitude: Double?
}

// MARK: - Requests

struct CreateProviderLocationRequest: Encodable {
    let label: String
    let country: String
    let city: String
    let zipCode: String
    let latitude: Double
    let longitude: Double
}
