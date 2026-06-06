import SwiftUI

/// One matched item from a Calculator or Agent result.
/// Provides an "Add to Cart" action that hits a synchronous lookup by id —
/// the caller injects a closure that resolves `MatchedItem.itemId` to an
/// `ItemDto` (so the cart entry carries the full multi-pricing payload).
struct MatchedItemRow: View {
    let item: MatchedItem
    /// Resolves the matched item id to the full `ItemDto` so cart entries
    /// carry `prices` (parity with the web add-to-cart payload).
    let resolveItem: (Int) async -> ItemDto?
    @EnvironmentObject private var appState: AppState

    @State private var isAdding = false
    @State private var added = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(item.name)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(2)
                    if item.lowestPrice {
                        Text("Lowest")
                            .font(.caption2.weight(.bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.accentColor.opacity(0.15), in: Capsule())
                            .foregroundStyle(.tint)
                    }
                }

                if let provider = item.providerName, !provider.isEmpty {
                    Text(provider)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text("\(item.price.currencyFormatted()) · \(item.availableQuantity) in stock")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                Task { await addToCart() }
            } label: {
                if isAdding {
                    ProgressView()
                } else if added {
                    Label("Added", systemImage: "checkmark")
                        .labelStyle(.iconOnly)
                        .foregroundStyle(.green)
                } else {
                    Image(systemName: "cart.badge.plus")
                }
            }
            .buttonStyle(.bordered)
            .disabled(isAdding || added)
            .accessibilityLabel(Text(L10n.t("common.add_to_cart")))
        }
        .padding(.vertical, 4)
    }

    private func addToCart() async {
        isAdding = true
        defer { isAdding = false }
        guard let dto = await resolveItem(item.itemId) else { return }
        appState.addToCart(dto)
        added = true
        try? await Task.sleep(for: .seconds(1.5))
        added = false
    }
}
