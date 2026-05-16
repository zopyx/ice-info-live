import SwiftUI

struct ICEInfoTheme: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    let appTheme: AppTheme

    var isDark: Bool {
        switch appTheme {
        case .light: return false
        case .dark: return true
        case .system: return colorScheme == .dark
        }
    }

    func body(content: Content) -> some View {
        content
            .environment(\.dbTheme, DBTheme(isDark: isDark))
    }
}

extension View {
    func iceInfoTheme(_ theme: AppTheme) -> some View {
        modifier(ICEInfoTheme(appTheme: theme))
    }
}
