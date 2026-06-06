import SwiftUI

struct ProductDetailView: View {
    let itemId: Int
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel: ProductDetailViewModel
    @State private var quantity = 1
    @State private var photoIndex = 0

    init(itemId: Int) {
        self.itemId = itemId
        _viewModel = StateObject(wrappedValue: ProductDetailViewModel(itemId: itemId))
    }

    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView().padding(.top, 80)
            } else if let item = viewModel.item {
                VStack(alignment: .leading, spacing: 0) {
                    photoCarousel(item: item)
                    detailBody(item: item)
                    relatedSection
                }
            } else if let error = viewModel.error {
                ContentUnavailableView(error, systemImage: "exclamationmark.triangle")
                    .padding(.top, 60)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
        .overlay(alignment: .bottom) {
            if let item = viewModel.item { addToCartBar(item: item) }
        }
        .overlay(alignment: .top) {
            if viewModel.addedToCart {
                addedConfirmation
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 8)
            }
        }
        .animation(.spring(duration: 0.3), value: viewModel.addedToCart)
    }

    // MARK: - Photo carousel

    private func photoCarousel(item: ItemDto) -> some View {
        TabView(selection: $photoIndex) {
            if let photos = item.photos, !photos.isEmpty {
                ForEach(Array(photos.enumerated()), id: \.element.id) { idx, photo in
                    AsyncPhotoView(url: photo.photoURL)
                        .frame(maxWidth: .infinity)
                        .frame(height: 300)
                        .clipped()
                        .tag(idx)
                }
            } else {
                AsyncPhotoView(url: nil)
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                    .clipped()
                    .tag(0)
            }
        }
        .tabViewStyle(.page)
        .frame(height: 300)
    }

    // MARK: - Detail body

    private func detailBody(item: ItemDto) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title + price
            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.title2.bold())

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(item.price.currencyFormatted())
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.tint)
                    Text("/ \(item.unit.displayLabel)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            // Meta info
            VStack(spacing: 0) {
                infoRow(label: "Provider", value: item.provider?.name ?? "—")
                infoRow(label: "Category", value: item.category?.displayLabel ?? "—")
                infoRow(label: "In Stock", value: "\(item.quantity) \(item.unit.displayLabel)")
                if let st = item.shippingTime {
                    infoRow(label: "Shipping Time", value: st)
                }
                if let serial = item.serialNumber {
                    infoRow(label: "Serial No.", value: serial)
                }
            }

            // Per-method pricing
            if let prices = item.prices, !prices.isEmpty {
                Divider()
                VStack(alignment: .leading, spacing: 8) {
                    Text("Pricing by Shipping Method")
                        .font(.subheadline.weight(.semibold))
                    ForEach(prices) { p in
                        HStack {
                            Text(p.shippingMethod.displayLabel)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(p.amount.currencyFormatted())
                                .font(.caption.weight(.semibold))
                        }
                    }
                }
            }
        }
        .padding()
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label).font(.subheadline).foregroundStyle(.secondary)
            Spacer()
            Text(value).font(.subheadline).fontWeight(.medium)
        }
        .padding(.vertical, 6)
    }

    // MARK: - Related

    @ViewBuilder
    private var relatedSection: some View {
        if !viewModel.relatedItems.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("More from this Provider")
                    .font(.headline)
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.relatedItems) { related in
                            NavigationLink(destination: ProductDetailView(itemId: related.id)) {
                                ItemCardView(item: related)
                                    .frame(width: 160)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, 100) // space for add-to-cart bar
        } else {
            Spacer().frame(height: 100)
        }
    }

    // MARK: - Add to Cart bar

    private func addToCartBar(item: ItemDto) -> some View {
        HStack(spacing: 16) {
            Stepper("\(quantity)", value: $quantity, in: 1...max(1, item.quantity))
                .labelsHidden()
                .fixedSize()

            Text("\(quantity)")
                .font(.title3.bold())
                .frame(width: 36)

            Button {
                viewModel.addToCart(appState: appState, quantity: quantity)
            } label: {
                Label("Add to Cart", systemImage: "cart.badge.plus")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(.thinMaterial)
    }

    private var addedConfirmation: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
            Text("Added to cart").font(.subheadline.weight(.medium))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.regularMaterial, in: Capsule())
        .shadow(radius: 4)
    }
}
