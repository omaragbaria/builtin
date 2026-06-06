import SwiftUI
import MapKit

struct OrderTrackingView: View {
    let initialDealId: Int?
    @StateObject private var viewModel = OrderTrackingViewModel()

    init(initialDealId: Int? = nil) {
        self.initialDealId = initialDealId
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                searchBar

                if viewModel.isLoading {
                    ProgressView().padding(.top, 40)
                } else if let error = viewModel.error {
                    ErrorBanner(message: error)
                } else if let delivery = viewModel.delivery {
                    stageTimeline(delivery: delivery)
                    if delivery.driverLatitude != nil && delivery.driverLongitude != nil {
                        driverMap(delivery: delivery)
                    } else if delivery.stage == .inDelivery {
                        driverPendingPanel
                    }
                    orderInfo(delivery: delivery)
                    lastUpdatedFooter
                }
            }
            .padding()
        }
        .navigationTitle("Track Order")
        .onAppear {
            if let id = initialDealId {
                viewModel.dealIdInput = "\(id)"
                Task { await viewModel.track(dealId: id) }
            }
        }
        .onDisappear { viewModel.stopPolling() }
    }

    // MARK: - Search bar

    private var searchBar: some View {
        HStack {
            TextField("Order number (Deal ID)", text: $viewModel.dealIdInput)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)

            Button("Track") {
                guard let id = Int(viewModel.dealIdInput) else { return }
                Task { await viewModel.track(dealId: id) }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.dealIdInput.isEmpty || viewModel.isLoading)
        }
    }

    // MARK: - Stage timeline

    private func stageTimeline(delivery: DeliveryDto) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Delivery Status")
                .font(.headline)
                .padding(.bottom, 12)

            ForEach(DeliveryStage.allCases, id: \.self) { stage in
                StageRow(
                    stage: stage,
                    isCurrent: delivery.stage == stage,
                    isCompleted: stage.sortOrder <= delivery.stage.sortOrder
                )
            }

            if let eta = delivery.eta {
                HStack {
                    Image(systemName: "clock")
                        .foregroundStyle(.secondary)
                    Text("ETA: \(eta.formatted(date: .omitted, time: .shortened))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Driver pending panel (M5 parity: fallback when stage is IN_DELIVERY but no coords yet)

    private var driverPendingPanel: some View {
        HStack(spacing: 10) {
            Image(systemName: "mappin.slash")
                .foregroundStyle(.orange)
            Text("Driver location not yet available")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }

    private var lastUpdatedFooter: some View {
        HStack {
            Image(systemName: "arrow.clockwise")
                .font(.caption2)
            Text("Updated \(Date.now.formatted(date: .omitted, time: .shortened))")
                .font(.caption2)
            Spacer()
        }
        .foregroundStyle(.secondary)
        .padding(.horizontal, 4)
    }

    // MARK: - Driver map

    private func driverMap(delivery: DeliveryDto) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Driver Location")
                .font(.headline)

            let coord = CLLocationCoordinate2D(
                latitude: delivery.driverLatitude ?? 0,
                longitude: delivery.driverLongitude ?? 0
            )
            Map {
                Annotation("Driver", coordinate: coord) {
                    ZStack {
                        Circle()
                            .fill(.blue)
                            .frame(width: 36, height: 36)
                        Image(systemName: driverIcon(for: delivery.vehicleType))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .mapStyle(.standard)
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Order info

    private func orderInfo(delivery: DeliveryDto) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Order Details")
                .font(.headline)

            infoRow("Order #", value: "\(delivery.dealId)")
            infoRow("Total", value: delivery.dealTotal.currencyFormatted())
            if let method = delivery.dealShippingMethod {
                infoRow("Shipping", value: method)
            }
            if let driver = delivery.deliveryAccountName {
                infoRow("Driver", value: driver)
            }
            if let vehicle = delivery.vehicleType {
                infoRow("Vehicle", value: vehicle.displayLabel)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }

    private func infoRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label).foregroundStyle(.secondary).font(.subheadline)
            Spacer()
            Text(value).font(.subheadline).fontWeight(.medium)
        }
    }

    private func driverIcon(for vehicle: VehicleType?) -> String {
        switch vehicle {
        case .bike, .motorbike: return "bicycle"
        case .car:              return "car.fill"
        case .truck, .largeTruck, .trailerTruck, .fridgeTruck, .mixedTruck, .truckWithWinch:
            return "truck.box.fill"
        case nil:               return "person.fill"
        }
    }
}

// MARK: - Stage row

private struct StageRow: View {
    let stage: DeliveryStage
    let isCurrent: Bool
    let isCompleted: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(isCompleted ? Color.accentColor : Color(.systemGray4))
                    .frame(width: 28, height: 28)
                Image(systemName: isCompleted ? "checkmark" : "circle")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(stage.customerLabel)
                    .font(isCurrent ? .subheadline.bold() : .subheadline)
                    .foregroundStyle(isCurrent ? .primary : .secondary)
                if isCurrent {
                    Text(stage.customerDescription)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if isCurrent {
                Text("Current")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tint)
            }
        }
        .padding(.vertical, 6)
    }
}
