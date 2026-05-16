import SwiftUI

struct StopTimePair: View {
    let scheduled: String
    let actual: String
    let delay: Int
    let isPassed: Bool
    let isNext: Bool
    var isCancelled: Bool = false

    private var isDelayed: Bool { delay > 0 && !isPassed && !isCancelled && !actual.isEmpty }

    var body: some View {
        let displayActual = actual.isEmpty ? scheduled : actual

        HStack(spacing: 4) {
            Text(scheduled)
                .font(.system(.caption, design: .monospaced))
                .fontWeight(isNext && !isDelayed && !isCancelled ? .semibold : .regular)
                .foregroundStyle {
                    if isCancelled { return .secondary.opacity(0.35) }
                    if isDelayed { return .secondary.opacity(0.5) }
                    if isPassed { return .primary.opacity(0.4) }
                    return .primary
                }
                .strikethrough(isDelayed || isCancelled)

            Text(displayActual)
                .font(.system(.caption, design: .monospaced))
                .fontWeight(isDelayed || isNext ? .bold : .regular)
                .foregroundStyle {
                    if isCancelled { return .secondary.opacity(0.35) }
                    if isPassed { return .primary.opacity(0.4) }
                    if isDelayed && delay >= 5 { return .red }
                    return .green
                }
                .strikethrough(isCancelled)
        }
    }
}

extension Text {
    @ViewBuilder
    func foregroundStyle(_ color: Color) -> some View {
        self.foregroundColor(color)
    }
}
