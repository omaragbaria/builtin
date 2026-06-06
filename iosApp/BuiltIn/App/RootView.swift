import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appState: AppState
    @State private var langTrigger = UUID()

    var body: some View {
        Group {
            if appState.isLoggedIn, let user = appState.currentUser {
                switch user.userType {
                case .customer, .enterpriseUser:
                    CustomerTabView()
                case .provider:
                    ProviderTabView()
                case .delivery:
                    DeliveryTabView()
                case .superAdmin:
                    AdminTabView()
                }
            } else {
                LoginView()
            }
        }
        .tint(Theme.amber)
        .environment(\.layoutDirection, L10n.current.isRTL ? .rightToLeft : .leftToRight)
        .id(langTrigger)
        .onReceive(NotificationCenter.default.publisher(for: .languageChanged)) { _ in
            langTrigger = UUID()
        }
    }
}

// MARK: - Tab roots

struct CustomerTabView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label(L10n.t("tab.home"), systemImage: "house") }

            NavigationStack {
                ProductsView()
            }
            .tabItem { Label(L10n.t("tab.products"), systemImage: "square.grid.2x2") }

            NavigationStack {
                EstimateView()
            }
            .tabItem { Label(L10n.t("tab.estimate"), systemImage: "function") }

            NavigationStack {
                CartView()
            }
            .badge(appState.cartCount > 0 ? appState.cartCount : 0)
            .tabItem { Label(L10n.t("tab.cart"), systemImage: "cart") }

            NavigationStack {
                OrderTrackingView(initialDealId: appState.lastDealId)
            }
            .tabItem { Label(L10n.t("tab.track"), systemImage: "location.circle") }

            NavigationStack {
                ProfileView()
            }
            .tabItem { Label(L10n.t("tab.profile"), systemImage: "person") }
        }
    }
}

struct ProviderTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                ProviderItemsView()
            }
            .tabItem { Label(L10n.t("provider.items"), systemImage: "shippingbox") }

            NavigationStack {
                ProviderLocationsView()
            }
            .tabItem { Label(L10n.t("tab.locations"), systemImage: "mappin.and.ellipse") }

            NavigationStack {
                ProfileView()
            }
            .tabItem { Label(L10n.t("tab.profile"), systemImage: "person") }
        }
    }
}

struct DeliveryTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                DeliveryDashboardView()
            }
            .tabItem { Label(L10n.t("tab.dashboard"), systemImage: "gauge") }

            NavigationStack {
                MyDeliveriesView()
            }
            .tabItem { Label(L10n.t("delivery.my_deliveries"), systemImage: "shippingbox.and.arrow.backward") }

            NavigationStack {
                ProfileView()
            }
            .tabItem { Label(L10n.t("tab.profile"), systemImage: "person") }
        }
    }
}

struct AdminTabView: View {
    var body: some View {
        TabView {
            NavigationStack { AdminDeliveriesView() }
                .tabItem { Label(L10n.t("tab.deliveries"), systemImage: "shippingbox") }

            NavigationStack { ProductsView() }
                .tabItem { Label(L10n.t("tab.items"), systemImage: "square.grid.2x2") }

            NavigationStack { AdminProvidersView() }
                .tabItem { Label(L10n.t("admin.providers"), systemImage: "building.2") }

            NavigationStack { ProfileView() }
                .tabItem { Label(L10n.t("tab.profile"), systemImage: "person") }
        }
    }
}
