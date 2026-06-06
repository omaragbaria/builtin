import SwiftUI

struct EstimateView: View {
    enum Mode: String, CaseIterable, Identifiable {
        case calculator, agent
        var id: String { rawValue }
        var label: String {
            switch self {
            case .calculator: return "Calculator"
            case .agent:      return "AI Agent"
            }
        }
    }

    @State private var mode: Mode = .calculator

    var body: some View {
        VStack(spacing: 0) {
            Picker("Tool", selection: $mode) {
                ForEach(Mode.allCases) { m in
                    Text(m.label).tag(m)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            switch mode {
            case .calculator: CalculatorView()
            case .agent:      AgentView()
            }
        }
        .navigationTitle("Estimate")
        .navigationBarTitleDisplayMode(.inline)
    }
}
