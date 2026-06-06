import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showLogoutConfirm = false
    @State private var selectedLanguage: L10n.Language = L10n.current

    var body: some View {
        List {
            if let user = appState.currentUser {
                Section {
                    HStack(spacing: 14) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(Theme.amber)
                            .symbolRenderingMode(.hierarchical)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(user.displayName).font(.headline)
                            Text(user.email).font(.caption).foregroundStyle(.secondary)
                            Text(user.userType.rawValue.capitalized)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Theme.amber.opacity(0.15), in: Capsule())
                                .foregroundStyle(Theme.amber)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            Section {
                Picker(selection: $selectedLanguage) {
                    ForEach(L10n.Language.allCases) { lang in
                        Text("\(lang.flag) \(lang.displayName)").tag(lang)
                    }
                } label: {
                    Label {
                        LocalizedText("profile.language")
                    } icon: {
                        Image(systemName: "globe")
                    }
                }
                .onChange(of: selectedLanguage) { _, new in
                    L10n.current = new
                }
            }

            Section {
                Button(role: .destructive) {
                    showLogoutConfirm = true
                } label: {
                    Label {
                        LocalizedText("profile.sign_out")
                    } icon: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
        }
        .navigationTitle(Text(L10n.t("profile.title")))
        .confirmationDialog(
            Text(L10n.t("profile.sign_out") + "?"),
            isPresented: $showLogoutConfirm,
            titleVisibility: .visible
        ) {
            Button(L10n.t("profile.sign_out"), role: .destructive) { appState.logout() }
            Button(L10n.t("common.cancel"), role: .cancel) {}
        }
    }
}
