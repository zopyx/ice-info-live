import SwiftUI

struct AppCard<Content: View>: View {
    @Environment(\.dbTheme) var theme
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .background(theme.surface)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(theme.divider, lineWidth: 0.75)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}
