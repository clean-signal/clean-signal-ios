import SwiftUI

struct ProductDetailView: View {
    let product: Product
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.productName ?? "Unknown Product")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    if let brand = product.brand {
                        Text(brand)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 16)

            // NOVA badge
            if let nova = product.novaGroup {
                HStack {
                    novaBadge(nova)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }

            // Macros card
            macrosCard
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

            // Ingredients
            if let ingredients = product.ingredientsText, !ingredients.isEmpty {
                ingredientsCard(ingredients)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
            }

            Spacer()
        }
        .background(Color(hex: "0D0D0D"))
    }

    private var macrosCard: some View {
        VStack(spacing: 16) {
            Text("Per 100g")
                .font(.caption)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 12) {
                macroItem(
                    value: product.energyKcal100g,
                    unit: "kcal",
                    label: "Calories",
                    color: .orange
                )
                macroItem(
                    value: product.proteins100g,
                    unit: "g",
                    label: "Protein",
                    color: .blue
                )
                macroItem(
                    value: product.carbohydrates100g,
                    unit: "g",
                    label: "Carbs",
                    color: .green
                )
                macroItem(
                    value: product.fat100g,
                    unit: "g",
                    label: "Fat",
                    color: .red
                )
            }
        }
        .padding(20)
        .background(Color(hex: "1A1A1A"))
        .cornerRadius(16)
    }

    private func macroItem(value: Double?, unit: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(formatValue(value))
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            Text(unit)
                .font(.caption2)
                .foregroundColor(.gray)

            Text(label)
                .font(.caption)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
    }

    private func ingredientsCard(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ingredients")
                .font(.caption)
                .foregroundColor(.gray)

            Text(text)
                .font(.footnote)
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(6)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "1A1A1A"))
        .cornerRadius(16)
    }

    private func novaBadge(_ group: Int) -> some View {
        let label: String
        let color: Color
        switch group {
        case 1:
            label = "Unprocessed"
            color = .green
        case 2:
            label = "Processed ingredients"
            color = .yellow
        case 3:
            label = "Processed"
            color = .orange
        case 4:
            label = "Ultra-processed"
            color = .red
        default:
            label = "NOVA \(group)"
            color = .gray
        }

        return HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text("NOVA \(group)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(color)
            Text("·")
                .foregroundColor(.gray)
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .cornerRadius(20)
    }

    private func formatValue(_ value: Double?) -> String {
        guard let v = value else { return "—" }
        if v == v.rounded() {
            return String(format: "%.0f", v)
        }
        return String(format: "%.1f", v)
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255
        )
    }
}
