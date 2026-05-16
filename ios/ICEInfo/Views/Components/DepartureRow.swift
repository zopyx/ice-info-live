import SwiftUI

struct DepartureRow: View {
    let dep: Departure

    var body: some View {
        HStack(spacing: 12) {
            DepartureTimePairView(
                scheduled: dep.scheduledTime,
                delayMinutes: dep.delayMinutes,
                cancelled: dep.cancelled
            )
            lineInfo
            Spacer()
            platformBadge
        }
        .padding(.vertical, 10)
    }

    private var lineInfo: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 6) {
                let parts = dep.line.split(separator: " ", maxSplits: 1)
                if parts.count == 2 {
                    TrainTypeBadge(type: String(parts[0]), muted: dep.cancelled)
                    Text(String(parts[1]))
                        .font(.body.weight(.bold))
                        .foregroundStyle(dep.cancelled ? Color.secondary.opacity(0.4) : Color.primary)
                } else {
                    Text(dep.line)
                        .font(.body.weight(.bold))
                }
                if dep.cancelled {
                    Text("Ausgefallen")
                        .font(.caption2.bold())
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(.systemRed).opacity(0.15))
                        .foregroundStyle(.red)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
            Text(dep.destination)
                .font(.caption)
                .foregroundStyle(.secondary.opacity(dep.cancelled ? 0.5 : 1))
                .lineLimit(1)
        }
    }

    private var platformBadge: some View {
        Group {
            if !dep.platform.isEmpty {
                Text("Gl. \(dep.platform)")
                    .font(.caption2.weight(.semibold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
        }
    }
}
