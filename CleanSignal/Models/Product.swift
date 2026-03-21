import Foundation

struct ProductResponse: Codable {
    let source: String?
    let product: Product?
    let error: String?
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
    }
}
