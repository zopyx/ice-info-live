import Foundation

enum BuildConfig {
    // DB API Marketplace credentials — set via environment or xcconfig in production
    static let dbClientId = ProcessInfo.processInfo.environment["DB_CLIENT_ID"] ?? ""
    static let dbApiKey = ProcessInfo.processInfo.environment["DB_API_KEY"] ?? ""
}
