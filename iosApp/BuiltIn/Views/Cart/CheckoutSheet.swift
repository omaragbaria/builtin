import SwiftUI
import MapKit

struct CheckoutSheet: View {
    @ObservedObject var viewModel: CartViewModel
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var deliveryCoordinate: CLLocationCoordinate2D?
    @State private var mapPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 31.7683, longitude: 35.2137), // Israel center
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        )
    )

    private var selectedMethod: ShippingMethod { appState.selectedShippingMethod }

    private var effectiveTotal: Decimal {
        appState.cart.reduce(Decimal.zero) { $0 + $1.effectiveSubtotal(for: selectedMethod) }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Shipping Method") {
                    ForEach(ShippingMethod.allCases, id: \.self) { method in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(method.displayLabel)
                                    .font(.subheadline)
                            }
                            Spacer()
                            if selectedMethod == method {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.tint)
                                    .font(.subheadline.weight(.semibold))
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { appState.selectedShippingMethod = method }
                    }
                }

                if selectedMethod == .immediate {
                    Section {
                        locationPicker
                    } header: {
                        Text("Drop-off Location")
                    } footer: {
                        Text("Tap the map to pin your delivery location.")
                            .font(.caption)
                    }
                }

                Section("Order Summary") {
                    ForEach(appState.cart) { item in
                        HStack {
                            Text(item.name).font(.subheadline).lineLimit(1)
                            Spacer()
                            Text("×\(item.quantity)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(item.effectiveSubtotal(for: selectedMethod).currencyFormatted())
                                .font(.subheadline.weight(.medium))
                        }
                    }
                    HStack {
                        Text("Total").font(.headline)
                        Spacer()
                        Text(effectiveTotal.currencyFormatted()).font(.headline)
                    }
                }

                if let error = viewModel.checkoutError {
                    Section {
                        Text(error)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Checkout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task { await placeOrder() }
                    } label: {
                        if viewModel.isCheckingOut {
                            ProgressView()
                        } else {
                            Text("Place Order")
                        }
                    }
                    .disabled(viewModel.isCheckingOut || (selectedMethod == .immediate && deliveryCoordinate == nil))
                }
            }
            .onChange(of: viewModel.checkoutSuccess) { _, success in
                if success { dismiss() }
            }
        }
        .presentationDetents([.large])
    }

    // MARK: - Location picker

    private var locationPicker: some View {
        MapReader { proxy in
            Map(position: $mapPosition) {
                if let coord = deliveryCoordinate {
                    Marker("Delivery Location", coordinate: coord)
                }
            }
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .onTapGesture { point in
                deliveryCoordinate = proxy.convert(point, from: .local)
            }
        }
        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
    }

    // MARK: -

    private func placeOrder() async {
        await viewModel.checkout(
            appState: appState,
            method: selectedMethod,
            deliveryLat: deliveryCoordinate?.latitude,
            deliveryLng: deliveryCoordinate?.longitude
        )
    }
}
