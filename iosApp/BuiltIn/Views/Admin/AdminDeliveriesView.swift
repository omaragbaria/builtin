import SwiftUI

struct AdminDeliveriesView: View {
    @StateObject private var viewModel = AdminDeliveriesViewModel()

    var body: some View {
        VStack(spacing: 0) {
            statsRow
                .padding(.horizontal)
                .padding(.bottom, 8)

            filterChips
                .padding(.horizontal)
                .padding(.bottom, 8)

            if viewModel.isLoading && viewModel.all.isEmpty {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.error {
                ErrorBanner(message: error).padding()
                Spacer()
            } else if viewModel.filtered.isEmpty {
                ContentUnavailableView(
                    L10n.t("delivery.my_deliveries"),
                    systemImage: "shippingbox",
                    description: Text(L10n.t("delivery.no_pending"))
                )
            } else {
                List {
                    ForEach(viewModel.filtered) { d in
                        AdminDeliveryRow(delivery: d)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle(Text(L10n.t("tab.deliveries")))
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }

    private var statsRow: some View {
        HStack(spacing: 8) {
            stat(value: viewModel.count(.pendingAssignment), label: L10n.t("delivery.pending"),     tint: Theme.warning)
            stat(value: viewModel.count(.accepted),          label: L10n.t("delivery.accepted"),    tint: Theme.info)
            stat(value: viewModel.count(.inDelivery),        label: L10n.t("delivery.in_delivery"), tint: Theme.primary)
            stat(value: viewModel.count(.arrived),           label: L10n.t("delivery.arrived"),     tint: Theme.success)
        }
    }

    private func stat(value: Int, label: String, tint: Color) -> some View {
        VStack(spacing: 2) {
            Text("\(value)").font(.title3.bold()).foregroundStyle(tint)
            Text(label).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8))
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip(label: L10n.t("delivery.tab_all_admin"), active: viewModel.filter == nil) {
                    viewModel.filter = nil
                }
                ForEach([DeliveryStage.pendingAssignment, .accepted, .inDelivery, .arrived], id: \.self) { s in
                    chip(label: stageLabel(s), active: viewModel.filter == s) {
                        viewModel.filter = s
                    }
                }
            }
        }
    }

    private func chip(label: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.caption.weight(.medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(active ? Theme.amber : Color(.secondarySystemBackground), in: Capsule())
                .foregroundStyle(active ? .white : .primary)
        }
        .buttonStyle(.plain)
    }

    private func stageLabel(_ s: DeliveryStage) -> String {
        switch s {
        case .pendingAssignment: return L10n.t("delivery.pending")
        case .accepted:          return L10n.t("delivery.accepted")
        case .inDelivery:        return L10n.t("delivery.in_delivery")
        case .arrived:           return L10n.t("delivery.arrived")
        }
    }
}

private struct AdminDeliveryRow: View {
    let delivery: DeliveryDto

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("#\(delivery.dealId)").font(.subheadline.weight(.semibold))
                Spacer()
                stageBadge(delivery.stage)
            }
            HStack(spacing: 8) {
                if let customer = delivery.customerName {
                    Label(customer, systemImage: "person").font(.caption)
                }
                if let courier = delivery.deliveryAccountName {
                    Label(courier, systemImage: "person.fill.checkmark").font(.caption)
                } else {
                    Label(L10n.t("delivery.unassigned"), systemImage: "questionmark.circle")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .foregroundStyle(.secondary)
            HStack {
                Text(delivery.dealTotal.currencyFormatted())
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.amber)
                Spacer()
                if let eta = delivery.eta {
                    Label(eta.formatted(date: .abbreviated, time: .shortened), systemImage: "clock")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
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
