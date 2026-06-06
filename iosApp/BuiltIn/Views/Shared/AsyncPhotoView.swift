import SwiftUI
import Kingfisher

struct AsyncPhotoView: View {
    let url: URL?
    var contentMode: SwiftUI.ContentMode = .fill

    var body: some View {
        KFImage(url)
            .placeholder { placeholder }
            .fade(duration: 0.2)
            .resizable()
            .aspectRatio(contentMode: contentMode)
    }

    private var placeholder: some View {
        Rectangle()
            .fill(Color(.systemGray5))
            .overlay(
                Image(systemName: "photo")
                    .foregroundStyle(Color(.systemGray3))
                    .font(.title2)
            )
    }
}
