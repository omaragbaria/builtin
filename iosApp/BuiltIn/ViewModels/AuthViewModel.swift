import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Mirrors the hardcoded credential map in webApp's AuthController
    private static let roleMap: [String: UserRole] = [
        "user":     .customer,
        "provider": .provider,
        "admin":    .superAdmin,
        "patara":   .provider,
        "dlv":      .delivery
    ]
    private static let validPassword = "1234"

    func login(appState: AppState) async {
        let key = username.lowercased().trimmingCharacters(in: .whitespaces)

        guard let role = Self.roleMap[key], Self.validPassword == password else {
            errorMessage = "Invalid username or password."
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            var providerId: Int? = nil
            var deliveryAccountId: Int? = nil
            var resolvedId = 0

            // Resolve the real user id from the DB so orders attach to this
            // account and appear under the Purchases tab.
            if let dbUser: UserDto = try? await APIClient.shared.request(
                .userByEmail(email: "\(key)@builtin.com")
            ) {
                resolvedId = dbUser.id
            }

            // Resolve real provider ID from DB for named provider accounts
            if key == "patara" {
                let providers: [ProviderDto] = try await APIClient.shared.request(.providers)
                providerId = providers.first {
                    $0.name.caseInsensitiveCompare("Patara") == .orderedSame
                }?.id
            }

            // Resolve delivery account ID from DB
            if role == .delivery {
                let email = "\(key)@builtin.com"
                if let account: DeliveryAccountDto = try? await APIClient.shared.request(
                    .deliveryAccountByEmail(email: email)
                ) {
                    deliveryAccountId = account.id
                }
            }

            let user = UserDto(
                id: resolvedId,
                firstName: key.capitalized,
                lastName: "Account",
                email: "\(key)@builtin.com",
                userType: role,
                providerId: providerId,
                deliveryAccountId: deliveryAccountId
            )

            appState.login(user: user)
            UserSession.save(user)

        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
