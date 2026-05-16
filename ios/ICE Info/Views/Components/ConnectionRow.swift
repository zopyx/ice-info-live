import SwiftUI

struct ConnectionRow: View {
    let conn: ConnectingTrain

    var body: some View {
        HStack(spacing: 12) {
            departureTime
            trainInfo
            Spacer()
            trackAndReachability
        }
        .padding(.vertical, 10)
    }

    private var departureTime: some View {
        DepartureTimePairView(scheduled: conn.departure, delayMinutes: conn.delayMinutes)
    }

    private var trainInfo: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 6) {
                TrainTypeBadge(type: conn.trainType)
                Text(conn.trainNumber)
                    .font(.body.weight(.bold))
            }
            Text(conn.destination)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }

    private var trackAndReachability: some View {
        VStack(alignment: .trailing, spacing: 4) {
            if !conn.track.isEmpty {
                Text("Gl. \(conn.track)")
                    .font(.caption2.weight(.semibold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }

            let isTight = conn.reachable && (conn.transferMinutes ?? 99) < 5
            Text(reachabilityText)
                .font(.caption2.bold())
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(reachabilityColor.opacity(0.15))
                .foregroundStyle(reachabilityColor)
                .clipShape(RoundedRectangle(cornerRadius: 4))

            if let min = conn.transferMinutes {
                Text("\(min) min Umstieg")
                    .font(.caption2)
                    .foregroundStyle(isTight ? .orange : .secondary)
            }
        }
    }

    private var reachabilityText: String {
        if !conn.reachable { return "Verpasst" }
        if (conn.transferMinutes ?? 99) < 5 { return "Knapp" }
        return "Erreichbar"
    }

    private var reachabilityColor: Color {
        if !conn.reachable { return .red }
        if (conn.transferMinutes ?? 99) < 5 { return .orange }
        return .green
    }
}

struct DepartureTimePairView: View {
    let scheduled: String
    let delayMinutes: Int
    var cancelled: Bool = false

    private var actual: String { addMinutesToTime(scheduled, delayMinutes) }
    private var isDelayed: Bool { delayMinutes > 0 && !cancelled }

    var body: some View {
        HStack(spacing: 4) {
            Text(scheduled)
                .font(.system(.body, design: .monospaced))
                .fontWeight(.semibold)
                .foregroundStyle {
                    if cancelled { return .secondary.opacity(0.35) as! Color }
                    if isDelayed { return .secondary.opacity(0.5) as! Color }
                    return .primary
                }
                .strikethrough(isDelayed || cancelled)

            Text(actual)
                .font(.system(.body, design: .monospaced))
                .fontWeight(.bold)
                .foregroundStyle {
                    if cancelled { return .secondary.opacity(0.35) as! Color }
                    if isDelayed && delayMinutes >= 5 { return .red }
                    return .green
                }
                .strikethrough(cancelled)
        }
    }

    private func addMinutesToTime(_ time: String, _ minutes: Int) -> String {
        let parts = time.split(separator: ":")
        guard parts.count == 2, let h = Int(parts[0]), let m = Int(parts[1]) else { return time }
        let total = h * 60 + m + minutes
        return String(format: "%02d:%02d", (total / 60) % 24, total % 60)
    }
}
