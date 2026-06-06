import SwiftUI

struct ProviderItemsView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = ProviderItemsViewModel()
    @State private var showAdd = false
    @State private var editing: ItemDto?

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.items.isEmpty {
                ProgressView()
            } else if let error = viewModel.error {
                ErrorBanner(message: error)
                    .padding()
            } else if viewModel.items.isEmpty {
                ContentUnavailableView {
                    Label(L10n.t("provider.items"), systemImage: "shippingbox")
                } description: {
                    Text(L10n.t("provider.add_item"))
                }
            } else {
                List {
                    ForEach(viewModel.items) { item in
                        Button {
                            editing = item
                        } label: {
                            ItemRowView(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle(Text(L10n.t("provider.items")))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAdd = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel(Text(L10n.t("provider.add_item")))
            }
        }
        .task { await load() }
        .refreshable { await load() }
        .sheet(isPresented: $showAdd) {
            NavigationStack {
                ItemFormView(
                    viewModel: ItemFormViewModel(existing: nil, providerId: appState.currentUser?.providerId),
                    onSaved: { Task { await load() } }
                )
            }
        }
        .sheet(item: $editing) { item in
            NavigationStack {
                ItemFormView(
                    viewModel: ItemFormViewModel(existing: item, providerId: appState.currentUser?.providerId),
                    onSaved: { Task { await load() } }
                )
            }
        }
    }

    private func load() async {
        guard let pid = appState.currentUser?.providerId else { return }
        await viewModel.load(providerId: pid)
    }
}
