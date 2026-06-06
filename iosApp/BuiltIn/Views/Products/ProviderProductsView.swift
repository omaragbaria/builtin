import SwiftUI

struct ProviderProductsView: View {
    let provider: ProviderDto
    @State private var items: [ItemDto] = []
    @State private var isLoading = false

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else if items.isEmpty {
                ContentUnavailableView("No Items", systemImage: "shippingbox")
            } else {
                List(items) { item in
                    NavigationLink(destination: ProductDetailView(itemId: item.id)) {
                        ItemRowView(item: item)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle(provider.name)
        .task {
            isLoading = true
            items = (try? await APIClient.shared.request(.providerItems(providerId: provider.id))) ?? []
            isLoading = false
        }
    }
}
