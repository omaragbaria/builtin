import SwiftUI

struct SearchView: View {
    let initialQuery: String

    @State private var query: String
    @State private var allItems: [ItemDto] = []
    @State private var isLoading = false

    init(initialQuery: String = "") {
        self.initialQuery = initialQuery
        _query = State(initialValue: initialQuery)
    }

    private var results: [ItemDto] {
        let q = query.lowercased().trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return allItems }
        return allItems.filter {
            $0.name.lowercased().contains(q)
            || ($0.category?.rawValue.lowercased().contains(q) ?? false)
            || ($0.type?.lowercased().contains(q) ?? false)
        }
    }

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else if results.isEmpty {
                ContentUnavailableView.search(text: query)
            } else {
                List(results) { item in
                    NavigationLink(destination: ProductDetailView(itemId: item.id)) {
                        ItemRowView(item: item)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search products…")
        .task {
            isLoading = true
            allItems = (try? await APIClient.shared.request(.items)) ?? []
            isLoading = false
        }
    }
}
