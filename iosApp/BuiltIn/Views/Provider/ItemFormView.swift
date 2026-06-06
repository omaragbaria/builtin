import SwiftUI

struct ItemFormView: View {
    @StateObject var viewModel: ItemFormViewModel
    var onSaved: () -> Void = {}
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section {
                TextField("Name", text: $viewModel.name)
                TextField("Type", text: $viewModel.type)

                Picker("Category", selection: $viewModel.category) {
                    Text("None").tag(ItemCategory?.none)
                    ForEach(ItemCategory.allCases, id: \.self) { cat in
                        Text(cat.displayLabel).tag(ItemCategory?.some(cat))
                    }
                }

                TextField("Serial number", text: $viewModel.serialNumber)
            }

            Section {
                HStack {
                    Text("Price").foregroundStyle(.secondary)
                    Spacer()
                    TextField("0", text: $viewModel.price)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Quantity").foregroundStyle(.secondary)
                    Spacer()
                    TextField("0", text: $viewModel.quantity)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                }
                Picker("Unit", selection: $viewModel.unit) {
                    ForEach(ItemUnit.allCases, id: \.self) { u in
                        Text(u.displayLabel).tag(u)
                    }
                }
            }

            Section {
                ForEach($viewModel.prices) { $row in
                    HStack(spacing: 8) {
                        Picker("", selection: $row.method) {
                            ForEach(ShippingMethod.allCases, id: \.self) { m in
                                Text(m.rawValue).tag(m)
                            }
                        }
                        .labelsHidden()
                        .frame(maxWidth: 110)

                        TextField("Amount", text: $row.amount)
                            .keyboardType(.decimalPad)

                        TextField("e.g. 24h", text: $row.deliveryTime)

                        Button(role: .destructive) {
                            viewModel.removePriceRow(id: row.id)
                        } label: {
                            Image(systemName: "trash")
                        }
                        .buttonStyle(.borderless)
                    }
                }
                Button {
                    viewModel.addPriceRow()
                } label: {
                    Label("Add Price", systemImage: "plus.circle")
                }
            } header: {
                Text("Prices by Shipping Method")
            } footer: {
                Text("Leave amount blank to fall back to the base price above.")
            }

            if let error = viewModel.error {
                Section {
                    Text(error).font(.footnote).foregroundStyle(.red)
                }
            }
        }
        .navigationTitle(viewModel.existing == nil ? L10n.t("provider.add_item") : "Edit Item")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(L10n.t("common.cancel")) { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    Task { await viewModel.save() }
                } label: {
                    if viewModel.isSaving {
                        ProgressView()
                    } else {
                        Text(L10n.t("common.save")).fontWeight(.semibold)
                    }
                }
                .disabled(viewModel.isSaving || viewModel.name.isEmpty)
            }
        }
        .onChange(of: viewModel.saveSuccess) { _, ok in
            if ok {
                onSaved()
                dismiss()
            }
        }
    }
}
