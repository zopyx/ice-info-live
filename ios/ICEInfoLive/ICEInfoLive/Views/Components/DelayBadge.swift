import SwiftUI

struct DelayBadge: View {
    let minutes: Int
    var size: Size = .small

    enum Size {
        case small
        case medium
    }

    var body: some View {
        if minutes > 0 {
            Text("+\(minutes)")
                .font(size == .small ? .caption2.bold() : .caption.bold())
                .foregroundColor(.white)
                .padding(.horizontal, size == .small ? 6 : 10)
                .padding(.vertical, size == .small ? 2 : 4)
                .background(Color.red)
                .cornerRadius(12)
        }
    }
}
