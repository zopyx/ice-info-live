import SwiftUI

struct DelayReasonCard: View {
    let reason: String

    var body: some View {
        AppCard {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(Color(red: 0.925, green: 0, blue: 0.086))
                    .font(.title3)
                Text(reason)
                    .font(.subheadline)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(red: 0.925, green: 0, blue: 0.086).opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}
