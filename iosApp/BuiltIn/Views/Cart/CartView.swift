import SwiftUI

struct CartView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = CartViewModel()
    @State private var showCheckoutSheet = false
    @State private var navigateToTracking = false

    private var method: ShippingMethod { appState.selectedShippingMethod }

    private var effectiveTotal: Decimal {
        appState.cart.reduce(Decimal.zero) { $0 + $1.effectiveSubtotal(for: method) }
    }

    var body: some View {
        Group {
            if appState.cart.isEmpty {
                emptyState
            } else {
                cartContent
            }
        }
        .navigationTitle("Cart")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showCheckoutSheet) {
            CheckoutSheet(viewModel: viewModel)
        }
        .navigationDestination(isPresented: $navigateToTracking) {
            if let dealId = viewModel.completedDealId {
                OrderTrackingView(initialDealId: dealId)
            }
        }
        .onChange(of: viewModel.checkoutSuccess) { _, success in
            if success { navigateToTracking = true }
        }
    }

    // MARK: - Cart content

    private var cartContent: some View {
        VStack(spacing: 0) {
            List {
                Section {
                    Picker("Shipping method", selection: $appState.selectedShippingMethod) {
                        ForEach(ShippingMethod.allCases, id: \.self) { m in
                            Text(m.shortLabel).tag(m)
                        }
                    }
                    .pickerStyle(.segmented)
                    .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                } header: {
                    Text("Shipping").font(.caption)
                }

                Section {
                    ForEach(appState.cart) { item in
                        CartItemRow(item: item, method: method)
                    }
                    .onDelete { offsets in
                        offsets.forEach { appState.removeFromCart(itemId: appState.cart[$0].itemId) }
                    }
                } header: {
                    Text("Items").font(.caption)
                }
            }
            .listStyle(.insetGrouped)

            summaryFooter
        }
    }

    // MARK: - Summary footer

    private var summaryFooter: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Total")
                    .font(.headline)
                Spacer()
                Text(effectiveTotal.currencyFormatted())
                    .font(.title3.bold())
                    .foregroundStyle(.tint)
            }

            if let error = viewModel.checkoutError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button {
                showCheckoutSheet = true
            } label: {
                Text("Proceed to Checkout")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isCheckingOut)
        }
        .padding()
        .background(.thinMaterial)
    }

    // MARK: - Empty state

    private var emptyState: some View {
        ContentUnavailableView {
            Label("Your Cart is Empty", systemImage: "cart")
        } description: {
            Text("Add items from the product catalog to get started.")
        }
    }
}

// MARK: - Cart item row

private struct CartItemRow: View {
    @EnvironmentObject private var appState: AppState
    let item: CartItemDto
    let method: ShippingMethod

    private var unitPrice: Decimal { item.effectivePrice(for: method) }
    private var subtotal: Decimal { item.effectiveSubtotal(for: method) }
    private var deliveryNote: String? { item.deliveryTime(for: method) }

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(2)

                if let provider = item.providerName {
                    Text(provider)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 4) {
                    Text(unitPrice.currencyFormatted())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if let deliveryNote, !deliveryNote.isEmpty {
                        Text("·").font(.caption).foregroundStyle(.secondary)
                        Text(deliveryNote)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(subtotal.currencyFormatted())
                    .font(.subheadline.bold())

                Stepper(
                    "\(item.quantity)",
                    value: Binding(
                        get: { item.quantity },
                        set: { appState.updateQuantity(itemId: item.itemId, quantity: $0) }
                    ),
                    in: 0...999
                )
                .labelsHidden()
                .fixedSize()
            }
        }
    }
}

private extension ShippingMethod {
    /// Compact label suited for the segmented picker.
    var shortLabel: String {
        switch self {
        case .selfPickup: return "Pickup"
        case .immediate:  return "Express"
        case .fast:       return "Fast"
        case .standard:   return "Standard"
        }
    }
}
