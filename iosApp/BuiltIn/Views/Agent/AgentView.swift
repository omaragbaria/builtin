import SwiftUI

struct AgentView: View {
    @StateObject private var viewModel = AgentViewModel()
    @State private var allItems: [ItemDto] = []
    @FocusState private var messageFocused: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                promptCard
                if let error = viewModel.error {
                    ErrorBanner(message: error)
                }
                if let response = viewModel.response {
                    resultsSection(response: response)
                }
            }
            .padding()
        }
        .task { await loadItems() }
    }

    // MARK: - Prompt

    private var promptCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Describe what you want to build")
                .font(.subheadline.weight(.semibold))

            ZStack(alignment: .topLeading) {
                if viewModel.message.isEmpty {
                    Text("e.g. I want a wall closet from oak wood, 4m wide, 60cm deep, 1.8m high")
                        .foregroundStyle(.secondary)
                        .padding(.top, 8)
                        .padding(.leading, 5)
                }
                TextEditor(text: $viewModel.message)
                    .focused($messageFocused)
                    .frame(minHeight: 100)
                    .scrollContentBackground(.hidden)
            }
            .background(Color(.tertiarySystemBackground), in: RoundedRectangle(cornerRadius: 8))

            Button {
                messageFocused = false
                Task { await viewModel.ask() }
            } label: {
                if viewModel.isLoading {
                    ProgressView().frame(maxWidth: .infinity)
                } else {
                    Text("Calculate Materials")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(viewModel.isLoading || viewModel.message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Results

    private func resultsSection(response: AgentResponse) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            if let summary = response.projectSummary, !summary.isEmpty {
                Text(summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            ForEach(response.materials) { line in
                materialCard(line: line)
            }
        }
    }

    private func materialCard(line: MaterialLine) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(line.materialType)
                    .font(.headline)
                Spacer()
                Text("\(line.requiredQuantity, specifier: "%g") \(line.unit)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.tint)
            }
            if line.matchedItems.isEmpty {
                Text("No matching items in catalog.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(line.matchedItems) { item in
                    MatchedItemRow(item: item) { id in
                        allItems.first { $0.id == id }
                    }
                    Divider().opacity(item.id == line.matchedItems.last?.id ? 0 : 1)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }

    private func loadItems() async {
        if !allItems.isEmpty { return }
        do {
            allItems = try await APIClient.shared.request(.items)
        } catch {
            // non-fatal — see CalculatorView.loadItems
        }
    }
}
