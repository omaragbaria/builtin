import Foundation

@MainActor
final class CalculatorViewModel: ObservableObject {
    enum StructureType: String, CaseIterable {
        case roofSlab = "ROOF_SLAB"
        case wall     = "WALL"

        var displayLabel: String {
            switch self {
            case .roofSlab: return "Roof / Floor Slab"
            case .wall:     return "Wall"
            }
        }
    }

    @Published var structureType: StructureType = .roofSlab
    @Published var length: String  = "5"
    @Published var width: String   = "4"
    @Published var height: String  = "3"
    @Published var thickness: String = "0.20"

    @Published var response: CalculatorResponse?
    @Published var error: String?
    @Published var isLoading = false

    func calculate() async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        let request = CalculatorRequest(
            structureType: structureType.rawValue,
            length:    Double(length)    ?? 0,
            width:     Double(width)     ?? 0,
            height:    Double(height)    ?? 0,
            thickness: Double(thickness) ?? 0
        )

        do {
            response = try await APIClient.shared.request(
                .calculatorCalculate,
                method: .post,
                body: request
            )
        } catch {
            self.error = error.localizedDescription
        }
    }
}
