import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case notFound
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .networkError(let error): return error.localizedDescription
        case .notFound: return "Product not found"
        case .serverError(let msg): return msg
        }
    }
}

class APIService {
    static let baseURL = "https://zijbiydtfezbbgyikcgc.supabase.co/functions/v1/lookup-barcode"

    static func lookupBarcode(_ barcode: String) async throws -> Product {
        guard let url = URL(string: baseURL) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["barcode": barcode])

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.serverError("Invalid response")
        }

        let decoded = try JSONDecoder().decode(ProductResponse.self, from: data)

        if httpResponse.statusCode == 404 {
            throw APIError.notFound
        }

        if let error = decoded.error {
            throw APIError.serverError(error)
        }

        guard let product = decoded.product else {
            throw APIError.notFound
        }

        return product
    }
}
