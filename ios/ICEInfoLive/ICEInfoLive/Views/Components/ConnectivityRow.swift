import SwiftUI

struct ConnectivityRow: View {
    @Environment(\.dbTheme) var theme
    let connectivity: ConnectivityState
    let wagonClass: Int

    var body: some View {
        HStack(spacing: 12) {
            // Wagon Class Card
            AppCard {
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(theme.primary)
                    Text("\(wagonClass). \(String(localized: "class_suffix"))")
                        .font(.subheadline.bold())
                        .foregroundColor(theme.textPrimary)
                }
            }

            // Connectivity Card
            AppCard {
                HStack {
                    Image(systemName: connectivityIcon)
                        .foregroundColor(connectivityColor)
                    Text(connectivityText)
                        .font(.subheadline.bold())
                        .foregroundColor(theme.textPrimary)
                }
            }
        }
    }

    private var connectivityIcon: String {
        switch connectivity {
        case .strong: return "wifi"
        case .weak: return "wifi.exclamationmark"
        case .noConnection: return "wifi.slash"
        case .noInfo: return "wifi"
        }
    }

    private var connectivityColor: Color {
        switch connectivity {
        case .strong: return .green
        case .weak: return .orange
        case .noConnection: return .red
        case .noInfo: return .gray
        }
    }

    private var connectivityText: String {
        switch connectivity {
        case .strong: return String(localized: "wifi_strong")
        case .weak: return String(localized: "wifi_weak")
        case .noConnection: return String(localized: "wifi_none")
        case .noInfo: return String(localized: "wifi_unknown")
        }
    }
}
