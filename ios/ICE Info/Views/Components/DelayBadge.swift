import SwiftUI

struct DelayBadge: View {
    let delayMinutes: Int

    var isSignificant: Bool { delayMinutes >= 5 }

    var body: some View {
        Text("+\(delayMinutes)")
            .font(.caption.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(isSignificant ? Color.red : Color.green)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
