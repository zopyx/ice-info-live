import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case httpError(Int)
    case networkError(Error)
    case allHostsFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .noData: return "No data received"
        case .decodingError(let error): return "Decoding error: \(error.localizedDescription)"
        case .httpError(let code): return "HTTP error: \(code)"
        case .networkError(let error): return "Network error: \(error.localizedDescription)"
        case .allHostsFailed: return "All hosts failed"
        }
    }
}
