import Foundation

struct ProductResponse: Codable {
    let source: String?
    let product: Product?
    let error: String?
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
