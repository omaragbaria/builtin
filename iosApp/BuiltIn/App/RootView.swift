import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
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
}

// MARK: - Tab root placeholders (replaced in later phases)

struct CustomerTabView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house") }

            NavigationStack {
                ProductsView()
            }
            .tabItem { Label("Products", systemImage: "square.grid.2x2") }

            NavigationStack {
                EstimateView()
            }
            .tabItem { Label("Estimate", systemImage: "function") }

            NavigationStack {
                CartView()
            }
            .badge(appState.cartCount > 0 ? appState.cartCount : 0)
            .tabItem { Label("Cart", systemImage: "cart") }

            NavigationStack {
                OrderTrackingView(initialDealId: appState.lastDealId)
            }
            .tabItem { Label("Track", systemImage: "location.circle") }

            NavigationStack {
                ProfileView()
            }
            .tabItem { Label("Profile", systemImage: "person") }
        }
    }
}

struct ProviderTabView: View {
    var body: some View {
        TabView {
            Text("My Items").tabItem { Label("Items", systemImage: "shippingbox") }
            Text("Locations").tabItem { Label("Locations", systemImage: "mappin.and.ellipse") }
            Text("Profile").tabItem { Label("Profile", systemImage: "person") }
        }
    }
}

struct DeliveryTabView: View {
    var body: some View {
        TabView {
            Text("Dashboard").tabItem { Label("Dashboard", systemImage: "gauge") }
            Text("My Deliveries").tabItem { Label("Deliveries", systemImage: "shippingbox.and.arrow.backward") }
            Text("Profile").tabItem { Label("Profile", systemImage: "person") }
        }
    }
}

struct AdminTabView: View {
    var body: some View {
        TabView {
            Text("Deliveries").tabItem { Label("Deliveries", systemImage: "shippingbox") }
            Text("Items").tabItem { Label("Items", systemImage: "square.grid.2x2") }
            Text("Providers").tabItem { Label("Providers", systemImage: "building.2") }
            Text("Profile").tabItem { Label("Profile", systemImage: "person") }
        }
    }
}

