import SwiftUI

struct ConnectivityRow: View {
    let status: TrainStatus
    let isDarkTheme: Bool

    private let connectivityState: ConnectivityState

    init(status: TrainStatus, isDarkTheme: Bool) {
        self.status = status
        self.isDarkTheme = isDarkTheme
        self.connectivityState = ConnectivityState(status: status, isDark: isDarkTheme)
    }

    var body: some View {
        HStack(spacing: 12) {
            wagonClassCard
            wifiCard
        }
    }

    private var wagonClassCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 4) {
                Text("KLASSE")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(wagonClassLabel(status.wagonClass))
                    .font(.title3.weight(.bold))
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var wifiCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("WLAN")
                        .font(.caption2)
                        .foregroundStyle(connectivityState.content)
                    Spacer()
                    if let next = status.nextConnectivity {
                        Text("\u{2192} \(connectivityLabel(next))")
                            .font(.caption2)
                            .foregroundStyle(connectivityState.nextContent)
                    }
                }
                HStack {
                    Text(connectivityLabel(status.connectivity))
                        .font(.title3.weight(.bold))
                        .foregroundStyle(connectivityState.content)
                    Spacer()
                    if let secs = status.connectivityRemainingSeconds {
                        Text("in \(formatRemainingSeconds(secs))")
                            .font(.caption2)
                            .foregroundStyle(connectivityState.nextContent)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(connectivityState.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private func wagonClassLabel(_ wc: String) -> String {
        switch wc {
        case "FIRST": return "1"
        case "SECOND": return "2"
        default: return "\u{2014}"
        }
    }

    private func connectivityLabel(_ conn: String) -> String {
        switch conn {
        case "STRONG", "HIGH": return "Stark"
        case "MIDDLE", "WEAK": return "Schwach"
        case "NO_INFO": return "\u{2014}"
        case "NO_CONNECTION", "LOW": return "Keine"
        default: return "\u{2014}"
        }
    }

    private func formatRemainingSeconds(_ secs: Int) -> String {
        guard secs > 0 else { return "" }
        let min = secs / 60
        return min > 0 ? "~\(min) min" : "<1 min"
    }
}

private struct ConnectivityState {
    let backgroundColor: Color
    let content: Color
    let nextContent: Color

    init(status: TrainStatus, isDark: Bool) {
        let current = Self.colorMap(status.connectivity, isDark: isDark)
        let next = status.nextConnectivity.flatMap { Self.colorMap($0, isDark: isDark) }
        backgroundColor = current.container
        content = current.content
        nextContent = next?.content ?? current.content
    }

    private static func colorMap(_ conn: String, isDark: Bool) -> (container: Color, content: Color) {
        switch conn {
        case "STRONG", "HIGH":
            return (isDark ? Color(red: 0.106, green: 0.369, blue: 0.125) : Color(red: 0.871, green: 0.929, blue: 0.839),
                    isDark ? Color(red: 0.871, green: 0.929, blue: 0.839) : Color(red: 0.251, green: 0.51, blue: 0.208))
        case "WEAK", "MIDDLE":
            return (isDark ? Color(red: 0.902, green: 0.318, blue: 0) : Color(red: 1, green: 0.878, blue: 0.698),
                    isDark ? Color(red: 1, green: 0.878, blue: 0.698) : Color(red: 0.902, green: 0.318, blue: 0))
        case "NO_CONNECTION", "LOW":
            return (Color(.systemRed).opacity(0.15), Color(.systemRed))
        default:
            return (Color(.systemGray5), Color(.systemGray))
        }
    }
}
