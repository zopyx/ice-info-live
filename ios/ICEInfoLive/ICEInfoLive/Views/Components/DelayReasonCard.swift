import SwiftUI

struct DelayReasonCard: View {
    @Environment(\.dbTheme) var theme
    let reasons: [String]

    var body: some View {
        if !reasons.isEmpty {
            AppCard {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text(reasons.joined(separator: ", "))
                        .font(.subheadline)
                        .foregroundColor(theme.textPrimary)
                    Spacer()
                }
            }
        }
    }
}
