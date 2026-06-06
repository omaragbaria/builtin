import Foundation

struct UserDto: Codable, Equatable {
    let id: Int
    let firstName: String
    let lastName: String
    let email: String
    let userType: UserRole
    let providerId: Int?
    let deliveryAccountId: Int?

    var displayName: String { "\(firstName) \(lastName)" }

    var canAddItems: Bool {
        userType == .provider || userType == .superAdmin
    }

    func canEdit(item: ItemDto) -> Bool {
        if userType == .superAdmin { return true }
        if userType == .provider, let pid = providerId, let provider = item.provider {
            return pid == provider.id
        }
        return false
    }
}

enum UserRole: String, Codable, Equatable {
    case customer       = "CUSTOMER"
    case provider       = "PROVIDER"
    case superAdmin     = "SUPER_ADMIN"
    case enterpriseUser = "ENTERPRISE_USER"
    case delivery       = "DELIVERY"
}

// MARK: - Login

struct LoginRequest: Encodable {
    let username: String
    let password: String
}
