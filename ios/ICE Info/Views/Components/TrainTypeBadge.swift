import SwiftUI

struct TrainTypeBadge: View {
    let type: String
    var muted: Bool = false

    var body: some View {
        Text(type)
            .font(.caption2.bold())
            .foregroundStyle(muted ? .secondary : Color(.systemBackground))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(muted ? Color(.systemGray5) : Color(red: 0.925, green: 0, blue: 0.086))
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}
