import SwiftUI

struct MyDeliveriesView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = DeliveryDashboardViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.mine.isEmpty {
                ProgressView()
            } else if viewModel.mine.isEmpty {
                ContentUnavailableView {
                    Label(L10n.t("delivery.my_deliveries"), systemImage: "shippingbox")
                } description: {
                    Text(L10n.t("delivery.no_mine"))
                }
            } else {
                List {
                    ForEach(viewModel.mine) { d in
                        MyDeliveryCard(delivery: d) { newStage in
                            Task {
                                await viewModel.updateStage(
                                    deliveryId: d.id,
                                    stage: newStage,
                                    accountId: appState.currentUser?.deliveryAccountId
                                )
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle(Text(L10n.t("delivery.my_deliveries")))
        .task { await load() }
        .refreshable { await load() }
    }

    private func load() async {
        await viewModel.load(accountId: appState.currentUser?.deliveryAccountId)
    }
}

private struct MyDeliveryCard: View {
    let delivery: DeliveryDto
    let onStageChange: (DeliveryStage) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("#\(delivery.dealId)").font(.headline)
                Spacer()
                stageBadge(delivery.stage)
            }
            Text(delivery.dealTotal.currencyFormatted())
                .font(.subheadline)
                .foregroundStyle(Theme.amber)
            if let customer = delivery.customerName {
                HStack(spacing: 4) {
                    Image(systemName: "person").font(.caption)
                    Text(customer).font(.caption)
                }
                .foregroundStyle(.secondary)
            }
            if delivery.stage != .arrived {
                Picker(selection: Binding(
                    get: { delivery.stage },
                    set: { onStageChange($0) }
                )) {
                    if delivery.stage == .accepted || delivery.stage == .inDelivery {
                        Text(L10n.t("delivery.accepted")).tag(DeliveryStage.accepted)
                    }
                    Text(L10n.t("delivery.in_delivery")).tag(DeliveryStage.inDelivery)
                    Text(L10n.t("delivery.arrived")).tag(DeliveryStage.arrived)
                } label: {
                    Text(L10n.t("delivery.update_stage"))
                }
                .pickerStyle(.menu)
            }
        }
        .padding(.vertical, 4)
    }

    private func stageBadge(_ stage: DeliveryStage) -> some View {
        let (tint, text): (Color, String) = {
            switch stage {
            case .pendingAssignment: return (Theme.warning, L10n.t("delivery.pending"))
            case .accepted:          return (Theme.info,    L10n.t("delivery.accepted"))
            case .inDelivery:        return (Theme.primary, L10n.t("delivery.in_delivery"))
            case .arrived:           return (Theme.success, L10n.t("delivery.arrived"))
            }
        }()
        return Text(text)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 6).padding(.vertical, 2)
            .background(tint.opacity(0.18), in: Capsule())
            .foregroundStyle(tint)
    }
}
