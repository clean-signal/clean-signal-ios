import SwiftUI

struct ProductDetailView: View {
    let product: Product
    let structuredIngredients: [StructuredIngredient]
    let onDismiss: () -> Void

    @State private var selectedIngredientId: IngredientSheetItem?

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                headerSection

                // Score concerns — only factors that lost points
                if let concerns = scoreConcerns, !concerns.isEmpty {
                    concernsSection(concerns)
                        .padding(.horizontal, 20)
                }

                // Macros
                macrosCard
                    .padding(.horizontal, 20)

                // Allergens
                if hasAllergenData {
                    allergensCard
                        .padding(.horizontal, 20)
                }

                // Additives
                if let additives = product.additives, !additives.isEmpty {
                    additivesCard(additives)
                        .padding(.horizontal, 20)
                }

                // Ingredients
                if !structuredIngredients.isEmpty {
                    ingredientsCard
                        .padding(.horizontal, 20)
                } else if let ingredients = product.ingredientsText, !ingredients.isEmpty {
                    ingredientsTextCard(ingredients)
                        .padding(.horizontal, 20)
                }

                // Analysis
                if hasAnalysisData {
                    analysisCard
                        .padding(.horizontal, 20)
                }

                Spacer(minLength: 40)
            }
        }
        .background(Color(hex: "0D0D0D"))
        .sheet(item: $selectedIngredientId) { item in
            IngredientDetailView(ingredientId: item.id)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(alignment: .top, spacing: 14) {
            // Product image
            if let urlString = product.imageSmallUrl, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 64, height: 64)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    default:
                        imagePlaceholder
                    }
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(product.productName ?? "Unknown Product")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                if let brand = product.brand {
                    Text(brand)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            // Score badge
            if let score = product.cleanScore {
                scoreBadge(score)
            }

            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 4)
    }

    private var imagePlaceholder: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(hex: "1A1A1A"))
            .frame(width: 64, height: 64)
            .overlay(
                Image(systemName: "fork.knife")
                    .foregroundColor(.gray)
            )
    }

    // MARK: - Score Badge

    private func scoreBadge(_ score: Int) -> some View {
        Text("\(score)")
            .font(.system(size: 24, weight: .bold, design: .rounded))
            .foregroundColor(scoreColor(score))
            .frame(width: 48, height: 48)
            .background(scoreColor(score).opacity(0.12))
            .cornerRadius(12)
    }

    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 80...100: return Color(hex: "1B8A2A")
        case 60..<80: return Color(hex: "85BB2F")
        case 40..<60: return Color(hex: "EE8100")
        default: return Color(hex: "E63E11")
        }
    }

    // MARK: - Concerns (only lost points, skip estimated)

    private var scoreConcerns: [ScoreBreakdown]? {
        product.cleanScoreBreakdown?.filter { $0.points < $0.maxPoints && $0.estimated != true }
    }

    private var estimatedCount: Int {
        product.cleanScoreBreakdown?.filter { $0.estimated == true }.count ?? 0
    }

    private func concernsSection(_ concerns: [ScoreBreakdown]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(concerns) { item in
                HStack(spacing: 8) {
                    Circle()
                        .fill(concernColor(points: item.points, max: item.maxPoints))
                        .frame(width: 6, height: 6)

                    Text(item.verdict)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))

                    Spacer()

                    Text("-\(Int(item.maxPoints - item.points))")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(concernColor(points: item.points, max: item.maxPoints))
                }
            }

            if estimatedCount > 0 {
                Text("Some nutritional data unavailable — score may change with more data")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.top, 4)
            }
        }
        .padding(16)
        .background(Color(hex: "1A1A1A"))
        .cornerRadius(12)
    }

    private func concernColor(points: Double, max: Double) -> Color {
        guard max > 0 else { return .gray }
        let ratio = points / max
        if ratio >= 0.7 { return Color(hex: "EE8100") }
        return Color(hex: "E63E11")
    }

    // MARK: - Macros Card

    private var macrosCard: some View {
        VStack(spacing: 16) {
            Text("Per 100g")
                .font(.caption)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 12) {
                macroItem(value: product.energyKcal100g, unit: "kcal", label: "Calories", color: .orange)
                macroItem(value: product.proteins100g, unit: "g", label: "Protein", color: .blue)
                macroItem(value: product.carbohydrates100g, unit: "g", label: "Carbs", color: .green)
                macroItem(value: product.fat100g, unit: "g", label: "Fat", color: .red)
            }

            if hasSecondaryMacros {
                Divider().background(Color.white.opacity(0.1))

                HStack(spacing: 12) {
                    secondaryMacro(value: product.saturatedFat100g, label: "Sat. Fat")
                    secondaryMacro(value: product.sugars100g, label: "Sugars")
                    secondaryMacro(value: product.salt100g, label: "Salt")
                    secondaryMacro(value: product.fiber100g, label: "Fiber")
                }
            }
        }
        .padding(20)
        .background(Color(hex: "1A1A1A"))
        .cornerRadius(16)
    }

    private var hasSecondaryMacros: Bool {
        product.saturatedFat100g != nil || product.sugars100g != nil ||
        product.salt100g != nil || product.fiber100g != nil
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

    private func secondaryMacro(value: Double?, label: String) -> some View {
        VStack(spacing: 4) {
            Text(formatValue(value))
                .font(.callout)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.8))
            Text("g")
                .font(.caption2)
                .foregroundColor(.gray)
            Text(label)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Allergens

    private var hasAllergenData: Bool {
        (product.allergens?.isEmpty == false) || (product.traces?.isEmpty == false)
    }

    private var allergensCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Allergens")
                .font(.caption)
                .foregroundColor(.gray)

            if let allergens = product.allergens, !allergens.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(allergens, id: \.self) { allergen in
                        tagPill(formatTag(allergen), color: .red)
                    }
                }
            }

            if let traces = product.traces, !traces.isEmpty {
                Text("May contain")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 2)

                FlowLayout(spacing: 8) {
                    ForEach(traces, id: \.self) { trace in
                        tagPill(formatTag(trace), color: .orange)
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "1A1A1A"))
        .cornerRadius(16)
    }

    // MARK: - Additives

    private func additivesCard(_ additives: [Additive]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Additives")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Text("\(additives.count)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.purple)
            }

            ForEach(additives) { additive in
                Button {
                    let eNumber = additive.additiveId.lowercased()
                    selectedIngredientId = IngredientSheetItem(id: "en:\(eNumber)")
                } label: {
                    HStack(spacing: 8) {
                        Text(additive.additiveId)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.purple)
                        Text(additive.name)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "1A1A1A"))
        .cornerRadius(16)
    }

    // MARK: - Ingredients

    /// Ingredients that have no children — the actual substances, not category wrappers
    private var leafIngredients: [StructuredIngredient] {
        let parentIds = Set(structuredIngredients.compactMap { $0.parentId })
        return structuredIngredients.filter { !parentIds.contains($0.ingredientId) }
    }

    /// Look up a parent's display name for context label
    private func parentName(for ingredient: StructuredIngredient) -> String? {
        guard let pid = ingredient.parentId else { return nil }
        return structuredIngredients.first { $0.ingredientId == pid }?.displayName
    }

    private var ingredientsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Ingredients")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Text("\(leafIngredients.count)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.5))
            }

            FlowLayout(spacing: 6) {
                ForEach(leafIngredients) { ingredient in
                    ingredientPill(ingredient)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "1A1A1A"))
        .cornerRadius(16)
    }

    private func ingredientPill(_ ingredient: StructuredIngredient) -> some View {
        let color = ingredientColor(ingredient)
        let context = parentName(for: ingredient)
        return Button {
            selectedIngredientId = IngredientSheetItem(id: ingredient.ingredientId)
        } label: {
            HStack(spacing: 4) {
                if ingredient.type == "additive" {
                    Circle().fill(color).frame(width: 5, height: 5)
                }
                Text(ingredient.displayName.localizedCapitalized)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
                if let context {
                    Text("(\(context))")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.35))
                }
                if let pct = ingredient.percentEstimate, pct >= 1 {
                    Text("\(Int(pct))%")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.4))
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.15))
            .cornerRadius(8)
        }
    }

    private func ingredientColor(_ ingredient: StructuredIngredient) -> Color {
        if let tier = ingredient.riskTier {
            switch tier {
            case "red": return Color(hex: "E63E11")
            case "caution": return Color(hex: "EE8100")
            case "positive": return Color(hex: "1B8A2A")
            default: break
            }
        }
        switch ingredient.type {
        case "additive": return .purple
        case "vitamin": return .cyan
        default: return .gray
        }
    }

    private func ingredientsTextCard(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Ingredients")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                if let count = product.ingredientsCount {
                    Text("\(count)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.5))
                }
            }

            Text(text)
                .font(.footnote)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "1A1A1A"))
        .cornerRadius(16)
    }

    // MARK: - Analysis

    private var hasAnalysisData: Bool {
        let hasVegan = product.veganStatus != nil && product.veganStatus != "unknown"
        let hasVeg = product.vegetarianStatus != nil && product.vegetarianStatus != "unknown"
        let hasEco = product.ecoscoreGrade != nil && product.ecoscoreGrade?.lowercased() != "unknown" && product.ecoscoreGrade?.lowercased() != "not-applicable"
        return hasVegan || hasVeg || hasEco
    }

    private var analysisCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Analysis")
                .font(.caption)
                .foregroundColor(.gray)

            FlowLayout(spacing: 8) {
                if let vegan = product.veganStatus, vegan != "unknown" {
                    statusPill("Vegan", value: vegan)
                }
                if let vegetarian = product.vegetarianStatus, vegetarian != "unknown" {
                    statusPill("Vegetarian", value: vegetarian)
                }
                if let eco = product.ecoscoreGrade?.lowercased(), !eco.isEmpty, eco != "unknown", eco != "not-applicable" {
                    ecoPill(eco)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "1A1A1A"))
        .cornerRadius(16)
    }

    private func statusPill(_ label: String, value: String) -> some View {
        let color = statusColor(value)
        return HStack(spacing: 4) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.12))
        .cornerRadius(8)
    }

    private func statusColor(_ value: String) -> Color {
        switch value.lowercased() {
        case "vegan", "vegetarian": return .green
        case "non-vegan", "non-vegetarian": return .red
        default: return .yellow
        }
    }

    private func ecoPill(_ grade: String) -> some View {
        let color: Color = {
            switch grade {
            case "a": return Color(hex: "1B8A2A")
            case "b": return Color(hex: "85BB2F")
            case "c": return Color(hex: "FECB02")
            case "d": return Color(hex: "EE8100")
            default: return Color(hex: "E63E11")
            }
        }()
        return HStack(spacing: 4) {
            Image(systemName: "leaf.fill")
                .font(.caption2)
                .foregroundColor(color)
            Text("Eco \(grade.uppercased())")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.12))
        .cornerRadius(8)
    }

    // MARK: - Helpers

    private func tagPill(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.2))
            .cornerRadius(8)
    }

    private func formatValue(_ value: Double?) -> String {
        guard let v = value else { return "—" }
        if v == v.rounded() { return String(format: "%.0f", v) }
        return String(format: "%.1f", v)
    }

    private func formatTag(_ tag: String) -> String {
        let cleaned = tag
            .replacingOccurrences(of: "en:", with: "")
            .replacingOccurrences(of: "-", with: " ")
        return cleaned.prefix(1).uppercased() + cleaned.dropFirst()
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrangeSubviews(proposal: proposal, subviews: subviews).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x - spacing)
        }

        return (CGSize(width: maxX, height: y + rowHeight), positions)
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
