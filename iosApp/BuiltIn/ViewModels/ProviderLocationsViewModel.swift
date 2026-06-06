import Foundation

@MainActor
final class ProviderLocationsViewModel: ObservableObject {
    @Published var locations: [ProviderLocationDto] = []
    @Published var isLoading = false
    @Published var error: String?

    func load(providerId: Int) async {
        isLoading = true
        error = nil
        defer { isLoading = false }
        do {
            locations = try await APIClient.shared.request(.providerLocations(providerId: providerId))
        } catch {
            self.error = error.localizedDescription
        }
    }

    func add(providerId: Int, request: CreateProviderLocationRequest) async -> Bool {
        do {
            let new: ProviderLocationDto = try await APIClient.shared.request(
                .createProviderLocation(providerId: providerId),
                method: .post,
                body: request
            )
            locations.append(new)
            return true
        } catch {
            self.error = error.localizedDescription
            return false
        }
    }

    func delete(providerId: Int, locationId: Int) async {
        do {
            try await APIClient.shared.requestVoid(
                .deleteProviderLocation(providerId: providerId, locationId: locationId),
                method: .delete
            )
            locations.removeAll { $0.id == locationId }
        } catch {
            self.error = error.localizedDescription
        }
    }
}
