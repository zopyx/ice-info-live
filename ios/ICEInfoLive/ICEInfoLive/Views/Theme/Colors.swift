import SwiftUI

extension Color {
    // MARK: - DB Brand Colors
    static let dbRed = Color(hex: "EC0016")
    static let dbBlue = Color(hex: "0076B6")
    static let dbDarkBlue = Color(hex: "131821")
    static let dbLightGray = Color(hex: "F0F3F5")
    static let dbGrayContainer = Color(hex: "E1E5EA")

    // MARK: - Semantic Colors
    static let connectivityStrong = Color.green
    static let connectivityWeak = Color.orange
    static let connectivityNone = Color.red
    static let connectivityUnknown = Color.gray

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct DBTheme {
    let isDark: Bool

    var background: Color {
        isDark ? .dbDarkBlue : .dbLightGray
    }

    var surface: Color {
        isDark ? Color(hex: "1E2433") : .white
    }

    var surfaceVariant: Color {
        isDark ? Color(hex: "2C3140") : .dbGrayContainer
    }

    var primary: Color {
        .dbRed
    }

    var onPrimary: Color {
        .white
    }

    var secondary: Color {
        .dbBlue
    }

    var textPrimary: Color {
        isDark ? .white : Color(hex: "131821")
    }

    var textSecondary: Color {
        isDark ? Color(hex: "A0A8B8") : Color(hex: "6B7280")
    }

    var divider: Color {
        isDark ? Color(hex: "2C3140") : Color(hex: "E1E5EA")
    }
}

private struct ThemeEnvironmentKey: EnvironmentKey {
    static let defaultValue = DBTheme(isDark: false)
}

extension EnvironmentValues {
    var dbTheme: DBTheme {
        get { self[ThemeEnvironmentKey.self] }
        set { self[ThemeEnvironmentKey.self] = newValue }
    }
}
