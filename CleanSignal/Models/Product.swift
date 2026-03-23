import Foundation

struct IngredientSheetItem: Identifiable {
    let id: String
}

struct StructuredIngredient: Codable, Identifiable {
    let ingredientId: String
    let name: String
    let type: String
    let riskTier: String?
    let percentEstimate: Double?
    let position: Int
    let depth: Int
    let parentId: String?

    var id: String { "\(ingredientId)-\(position)" }

    var displayName: String {
        ingredientId
            .replacingOccurrences(of: "en:", with: "")
            .replacingOccurrences(of: "-", with: " ")
    }

    enum CodingKeys: String, CodingKey {
        case ingredientId = "id"
        case name
        case type
        case riskTier = "risk_tier"
        case percentEstimate = "percent_estimate"
        case position
        case depth
        case parentId = "parent_id"
    }
}

struct IngredientDetail: Codable {
    let id: String
    let name: String
    let type: String
    let riskTier: String?
    let riskReason: String?
    let vegan: String?
    let vegetarian: String?
    let description: String?
    let productCount: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, type, vegan, vegetarian, description
        case riskTier = "risk_tier"
        case riskReason = "risk_reason"
        case productCount = "product_count"
    }
}

struct IngredientResponse: Codable {
    let ingredient: IngredientDetail?
    let products: [IngredientProduct]?
    let error: String?
}

struct IngredientProduct: Codable, Identifiable {
    var id: String { barcode }
    let barcode: String
    let productName: String?
    let brand: String?
    let cleanScore: Int?
    let imageSmallUrl: String?

    enum CodingKeys: String, CodingKey {
        case barcode
        case productName = "product_name"
        case brand
        case cleanScore = "clean_score"
        case imageSmallUrl = "image_small_url"
    }
}

struct ProductResponse: Codable {
    let source: String?
    let product: Product?
    let structuredIngredients: [StructuredIngredient]?
    let error: String?

    enum CodingKeys: String, CodingKey {
        case source
        case product
        case structuredIngredients = "structured_ingredients"
        case error
    }
}

struct ScoreBreakdown: Codable, Identifiable {
    var id: String { factor }
    let factor: String
    let points: Double
    let maxPoints: Double
    let verdict: String
    let estimated: Bool?

    enum CodingKeys: String, CodingKey {
        case factor
        case points
        case maxPoints = "maxPoints"
        case verdict
        case estimated
    }
}

struct Additive: Codable, Identifiable {
    var id: String { additiveId }
    let additiveId: String
    let name: String

    enum CodingKeys: String, CodingKey {
        case additiveId = "id"
        case name
    }
}

struct Product: Codable, Identifiable {
    var id: String { barcode }

    let barcode: String
    let productName: String?
    let brand: String?
    let energyKcal100g: Double?
    let proteins100g: Double?
    let carbohydrates100g: Double?
    let fat100g: Double?
    let novaGroup: Int?
    let ingredientsText: String?
    let nutriscoreGrade: String?
    let nutriscoreScore: Int?
    let imageUrl: String?
    let imageSmallUrl: String?
    let ingredientsCount: Int?
    let additives: [Additive]?
    let allergens: [String]?
    let traces: [String]?
    let hasPalmOil: Bool?
    let hasSeedOil: Bool?
    let veganStatus: String?
    let vegetarianStatus: String?
    let ecoscoreGrade: String?
    let saturatedFat100g: Double?
    let sugars100g: Double?
    let salt100g: Double?
    let fiber100g: Double?
    let cleanScore: Int?
    let cleanScoreBreakdown: [ScoreBreakdown]?

    enum CodingKeys: String, CodingKey {
        case barcode
        case productName = "product_name"
        case brand
        case energyKcal100g = "energy_kcal_100g"
        case proteins100g = "proteins_100g"
        case carbohydrates100g = "carbohydrates_100g"
        case fat100g = "fat_100g"
        case novaGroup = "nova_group"
        case ingredientsText = "ingredients_text"
        case nutriscoreGrade = "nutriscore_grade"
        case nutriscoreScore = "nutriscore_score"
        case imageUrl = "image_url"
        case imageSmallUrl = "image_small_url"
        case ingredientsCount = "ingredients_count"
        case additives
        case allergens
        case traces
        case hasPalmOil = "has_palm_oil"
        case hasSeedOil = "has_seed_oil"
        case veganStatus = "vegan_status"
        case vegetarianStatus = "vegetarian_status"
        case ecoscoreGrade = "ecoscore_grade"
        case saturatedFat100g = "saturated_fat_100g"
        case sugars100g = "sugars_100g"
        case salt100g = "salt_100g"
        case fiber100g = "fiber_100g"
        case cleanScore = "clean_score"
        case cleanScoreBreakdown = "clean_score_breakdown"
    }
}
