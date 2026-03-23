import SwiftUI

struct IngredientDetailView: View {
    let ingredientId: String

    @Environment(\.dismiss) private var dismiss
    @State private var ingredient: IngredientDetail?
    @State private var products: [IngredientProduct] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .frame(maxWidth: .infinity, minHeight: 200)
                } else if let error = errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.title2)
                            .foregroundColor(.orange)
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, minHeight: 200)
                } else if let ing = ingredient {
                    VStack(spacing: 16) {
                        headerSection(ing)
                        if let desc = ing.description, !desc.isEmpty {
                            descriptionCard(desc)
                        }
                        detailsCard(ing)
                        if !products.isEmpty {
                            productsCard
                        }
                        Spacer(minLength: 40)
                    }
                }
            }
            .background(Color(hex: "0D0D0D"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .task { await loadIngredient() }
    }

    // MARK: - Header

    private func headerSection(_ ing: IngredientDetail) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Text(ing.name.localizedCapitalized)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Spacer()

                if let tier = ing.riskTier {
                    riskBadge(tier)
                }
            }

            HStack(spacing: 8) {
                typePill(ing.type)

                if let count = ing.productCount, count > 0 {
                    Text("Found in \(count) product\(count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }

    private func riskBadge(_ tier: String) -> some View {
        let (label, color): (String, Color) = {
            switch tier {
            case "red": return ("Avoid", Color(hex: "E63E11"))
            case "caution": return ("Caution", Color(hex: "EE8100"))
            case "positive": return ("Positive", Color(hex: "1B8A2A"))
            default: return (tier.capitalized, .gray)
            }
        }()
        return Text(label)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.15))
            .cornerRadius(8)
    }

    private func typePill(_ type: String) -> some View {
        let color: Color = {
            switch type {
            case "additive": return .purple
            case "vitamin": return .cyan
            default: return .gray
            }
        }()
        return Text(type.capitalized)
            .font(.caption)
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.12))
            .cornerRadius(6)
    }

    // MARK: - Description

    private func descriptionCard(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundColor(.white.opacity(0.8))
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: "1A1A1A"))
            .cornerRadius(16)
            .padding(.horizontal, 20)
    }

    // MARK: - Details

    private func detailsCard(_ ing: IngredientDetail) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.caption)
                .foregroundColor(.gray)

            if let reason = ing.riskReason, !reason.isEmpty {
                detailRow(icon: "exclamationmark.triangle", label: "Risk", value: reason)
            }

            if let vegan = ing.vegan, vegan != "unknown" {
                detailRow(icon: "leaf", label: "Vegan", value: vegan.capitalized)
            }

            if let vegetarian = ing.vegetarian, vegetarian != "unknown" {
                detailRow(icon: "leaf.fill", label: "Vegetarian", value: vegetarian.capitalized)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "1A1A1A"))
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }

    private func detailRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.gray)
                .frame(width: 16)
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
    }

    // MARK: - Products containing this ingredient

    private var productsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Found in")
                .font(.caption)
                .foregroundColor(.gray)

            ForEach(products) { product in
                HStack(spacing: 12) {
                    if let urlString = product.imageSmallUrl, let url = URL(string: urlString) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 36, height: 36)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            default:
                                productImagePlaceholder
                            }
                        }
                    } else {
                        productImagePlaceholder
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(product.productName ?? "Unknown")
                            .font(.caption)
                            .foregroundColor(.white)
                            .lineLimit(1)
                        if let brand = product.brand {
                            Text(brand)
                                .font(.caption2)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                        }
                    }

                    Spacer()

                    if let score = product.cleanScore {
                        Text("\(score)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(scoreColor(score))
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "1A1A1A"))
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }

    private var productImagePlaceholder: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color(hex: "2A2A2A"))
            .frame(width: 36, height: 36)
            .overlay(
                Image(systemName: "fork.knife")
                    .font(.caption2)
                    .foregroundColor(.gray)
            )
    }

    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 80...100: return Color(hex: "1B8A2A")
        case 60..<80: return Color(hex: "85BB2F")
        case 40..<60: return Color(hex: "EE8100")
        default: return Color(hex: "E63E11")
        }
    }

    // MARK: - Data loading

    private func loadIngredient() async {
        do {
            let response = try await APIService.lookupIngredient(ingredientId)
            await MainActor.run {
                ingredient = response.ingredient
                products = response.products ?? []
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}
