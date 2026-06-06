import SwiftUI

struct ItemRowView: View {
    let item: ItemDto

    var body: some View {
        HStack(spacing: 12) {
            AsyncPhotoView(url: item.photos?.first?.photoURL)
                .frame(width: 68, height: 68)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(2)

                if let provider = item.provider {
                    Text(provider.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text("\(item.price.currencyFormatted()) / \(item.unit.displayLabel)")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.tint)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}
