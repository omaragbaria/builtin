import SwiftUI

struct PurchasesView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = PurchasesViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.deals.isEmpty {
                ProgressView()
            } else if viewModel.deals.isEmpty {
                ContentUnavailableView {
                    Label(L10n.t("tab.purchases"), systemImage: "bag")
                } description: {
                    Text(L10n.t("purchases.empty"))
                }
            } else {
                List {
                    ForEach(viewModel.deals) { deal in
                        NavigationLink {
                            OrderTrackingView(initialDealId: deal.id)
                        } label: {
                            PurchaseRow(deal: deal)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle(Text(L10n.t("tab.purchases")))
        .task { await load() }
        .refreshable { await load() }
    }

    private func load() async {
        await viewModel.load(userId: appState.currentUser?.id)
    }
}

private struct PurchaseRow: View {
    let deal: DealDto

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("#\(deal.id)").font(.headline)
                Spacer()
                statusBadge(deal.status)
            }
            HStack {
                Text(deal.totalPrice.currencyFormatted())
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.amber)
                Spacer()
                if let method = deal.shippingMethod {
                    Label(method.displayLabel, systemImage: "shippingbox")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            if let date = deal.dealDate {
                Text(date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private func statusBadge(_ status: DealStatus) -> some View {
        let tint: Color = {
            switch status {
            case .pendingApproval: return Theme.warning
            case .processing:      return Theme.info
            case .delivery:        return Theme.primary
            case .complete:        return Theme.success
            case .canceled:        return Theme.danger
            }
        }()
        return Text(status.displayLabel)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8).padding(.vertical, 3)
            .background(tint.opacity(0.18), in: Capsule())
            .foregroundStyle(tint)
    }
}
