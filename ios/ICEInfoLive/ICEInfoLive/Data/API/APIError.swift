import Foundation

enum APIError: Error, Equatable {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case noData
    case httpFallbackRequired
    case serverError(statusCode: Int)
    case unknown

    static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.noData, .noData),
             (.httpFallbackRequired, .httpFallbackRequired),
             (.unknown, .unknown):
            return true
        case let (.serverError(l), .serverError(r)):
            return l == r
        default:
            return false
        }
    }
}
