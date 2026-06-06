import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = AuthViewModel()
    @FocusState private var focused: Field?

    private enum Field { case username, password }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                header
                    .padding(.top, 72)
                    .padding(.bottom, 48)

                form
                    .padding(.horizontal, 32)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .onTapGesture { focused = nil }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 10) {
            Image(systemName: "building.2.crop.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(.tint)
                .symbolRenderingMode(.hierarchical)

            Text("BuiltIn")
                .font(.largeTitle.bold())

            Text("Building Materials Platform")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Form

    private var form: some View {
        VStack(spacing: 14) {
            TextField("Username", text: $viewModel.username)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused($focused, equals: .username)
                .submitLabel(.next)
                .onSubmit { focused = .password }

            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(.roundedBorder)
                .focused($focused, equals: .password)
                .submitLabel(.go)
                .onSubmit { attemptLogin() }

            errorBanner

            Button(action: attemptLogin) {
                Group {
                    if viewModel.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Sign In").fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 46)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading || viewModel.username.isEmpty || viewModel.password.isEmpty)
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.errorMessage != nil)
    }

    @ViewBuilder
    private var errorBanner: some View {
        if let msg = viewModel.errorMessage {
            HStack(alignment: .top, spacing: 6) {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundStyle(.red)
                Text(msg)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }

    // MARK: -

    private func attemptLogin() {
        guard !viewModel.isLoading else { return }
        focused = nil
        Task { await viewModel.login(appState: appState) }
    }
}

#Preview {
    LoginView()
        .environmentObject(AppState())
}
