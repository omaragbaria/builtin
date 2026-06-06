import SwiftUI

struct DeliveryDashboardView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = DeliveryDashboardViewModel()
    @StateObject private var broadcaster = LocationBroadcaster()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                statsRow

                broadcastBanner

                Text(L10n.t("delivery.pending"))
                    .font(.headline)
                    .padding(.top, 4)

                if let error = viewModel.error {
                    ErrorBanner(message: error)
                }

                if viewModel.pending.isEmpty {
                    emptyCard(text: L10n.t("delivery.no_pending"))
                } else {
                    ForEach(viewModel.pending) { d in
                        pendingCard(delivery: d)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(Text(L10n.t("delivery.dashboard")))
        .task { await load() }
        .refreshable { await load() }
        .onChange(of: viewModel.hasActiveDelivery) { _, active in
            broadcaster.setEnabled(active)
        }
        .onAppear {
            broadcaster.setEnabled(viewModel.hasActiveDelivery)
        }
        .onDisappear {
            // keep broadcasting in the background — webApp parity is to keep
            // sending while driver has active packages, not while the screen
            // is on. If you want to stop on background, swap this for false.
        }
    }

    private var statsRow: some View {
        HStack(spacing: 8) {
            statCell(value: viewModel.pending.count, label: L10n.t("delivery.pending"), tint: Theme.warning)
            statCell(value: viewModel.count(.accepted), label: L10n.t("delivery.accepted"), tint: Theme.info)
            statCell(value: viewModel.count(.inDelivery), label: L10n.t("delivery.in_delivery"), tint: Theme.primary)
            statCell(value: viewModel.count(.arrived), label: L10n.t("delivery.arrived"), tint: Theme.success)
        }
    }

    private func statCell(value: Int, label: String, tint: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.title.bold())
                .foregroundStyle(tint)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
    }

    @ViewBuilder
    private var broadcastBanner: some View {
        switch broadcaster.status {
        case .denied:
            banner(systemImage: "location.slash", tint: .red,
                   text: "Location permission denied. Customers cannot see your live position.")
        case .unavailable:
            banner(systemImage: "exclamationmark.triangle", tint: .orange,
                   text: "GPS unavailable on this device.")
        case .broadcasting:
            banner(systemImage: "dot.radiowaves.up.forward", tint: Theme.success,
                   text: "Broadcasting your GPS location to customers.")
        default:
            EmptyView()
        }
    }

    private func banner(systemImage: String, tint: Color, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage).foregroundStyle(tint)
            Text(text).font(.footnote).foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12).padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tint.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
    }

    private func emptyCard(text: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "tray")
                .font(.system(size: 28))
                .foregroundStyle(.tertiary)
            Text(text).font(.footnote).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }

    private func pendingCard(delivery d: DeliveryDto) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("#\(d.dealId)").font(.headline)
                Spacer()
                if let m = d.dealShippingMethod {
                    Text(m).font(.caption2).padding(.horizontal, 6).padding(.vertical, 2)
                        .background(Color.gray.opacity(0.15), in: Capsule())
                }
            }
            Text(d.dealTotal.currencyFormatted())
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.amber)
            Button {
                Task {
                    guard let accountId = appState.currentUser?.deliveryAccountId else { return }
                    await viewModel.accept(deliveryId: d.id, accountId: accountId)
                }
            } label: {
                Label(L10n.t("delivery.accept"), systemImage: "checkmark.circle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.success)
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }

    private func load() async {
        await viewModel.load(accountId: appState.currentUser?.deliveryAccountId)
    }
}
