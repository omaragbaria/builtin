import SwiftUI

struct ItemCardView: View {
    let item: ItemDto

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AsyncPhotoView(url: item.photos?.first?.photoURL)
                .frame(height: 140)
                .clipped()

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(2)
                    .foregroundStyle(.primary)

                if let provider = item.provider {
                    Text(provider.name)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Text("\(item.price.currencyFormatted()) / \(item.unit.displayLabel)")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tint)
            }
            .padding(10)
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
