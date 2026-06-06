import Foundation

@MainActor
final class AgentViewModel: ObservableObject {
    @Published var message: String = ""
    @Published var response: AgentResponse?
    @Published var error: String?
    @Published var isLoading = false

    func ask() async {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            response = try await APIClient.shared.request(
                .agentCalculate,
                method: .post,
                body: AgentRequest(message: trimmed)
            )
        } catch {
            self.error = error.localizedDescription
        }
    }
}
