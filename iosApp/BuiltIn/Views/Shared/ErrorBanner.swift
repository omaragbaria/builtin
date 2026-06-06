import SwiftUI

struct ErrorBanner: View {
    let message: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.circle.fill")
            Text(message)
                .font(.footnote)
            Spacer()
        }
        .foregroundStyle(.white)
        .padding(12)
        .background(Color.red.gradient, in: RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
    }
}
