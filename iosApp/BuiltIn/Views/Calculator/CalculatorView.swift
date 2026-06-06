import SwiftUI

struct CalculatorView: View {
    @StateObject private var viewModel = CalculatorViewModel()
    @State private var allItems: [ItemDto] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                inputForm
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

    // MARK: - Form

    private var inputForm: some View {
        VStack(alignment: .leading, spacing: 14) {
            Picker("Structure", selection: $viewModel.structureType) {
                ForEach(CalculatorViewModel.StructureType.allCases, id: \.self) { t in
                    Text(t.displayLabel).tag(t)
                }
            }
            .pickerStyle(.segmented)

            HStack {
                dimensionField(label: "Length (m)", text: $viewModel.length)
                if viewModel.structureType == .roofSlab {
                    dimensionField(label: "Width (m)", text: $viewModel.width)
                } else {
                    dimensionField(label: "Height (m)", text: $viewModel.height)
                }
            }
            dimensionField(label: "Thickness (m)", text: $viewModel.thickness)

            Button {
                Task { await viewModel.calculate() }
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
            .disabled(viewModel.isLoading)
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }

    private func dimensionField(label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.caption).foregroundStyle(.secondary)
            TextField("0", text: text)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
        }
    }

    // MARK: - Results

    private func resultsSection(response: CalculatorResponse) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            if let summary = response.structureSummary, !summary.isEmpty {
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

    // MARK: - Catalog cache (so MatchedItemRow can resolve to full ItemDto)

    private func loadItems() async {
        if !allItems.isEmpty { return }
        do {
            allItems = try await APIClient.shared.request(.items)
        } catch {
            // Non-fatal: matched-row "Add to Cart" will silently fail until catalog loads
        }
    }
}
