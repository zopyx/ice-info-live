import Foundation

func calculateDelayMinutes(actualMs: Int64, scheduledMs: Int64) -> Int {
    guard actualMs > 0 && scheduledMs > 0 else { return 0 }
    return Int((actualMs - scheduledMs) / 60_000)
}

func formatRemainingTime(distanceMeters: Int, speedKmh: Int) -> String {
    guard speedKmh > 0 else { return "--" }
    let remainingMinutes = Int((Float(distanceMeters) / 1000.0 / Float(speedKmh)) * 60)
    let hours = remainingMinutes / 60
    let minutes = remainingMinutes % 60
    if hours > 0 {
        return "\(hours)h \(minutes)min"
    }
    return "\(minutes)min"
}

func formatRemainingTimeUntil(scheduledArrival: String, delayMinutes: Int) -> String {
    guard !scheduledArrival.isEmpty else { return "--" }
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    formatter.timeZone = TimeZone.current
    guard let arrival = formatter.date(from: scheduledArrival) else { return "--" }

    let now = Date()
    var diffMinutes = Calendar.current.dateComponents([.minute], from: now, to: arrival).minute ?? 0
    diffMinutes += delayMinutes

    if diffMinutes < -60 {
        diffMinutes += 24 * 60
    }
    if diffMinutes < 0 {
        return "0min"
    }
    let hours = diffMinutes / 60
    let minutes = diffMinutes % 60
    if hours > 0 {
        return "\(hours)h \(minutes)min"
    }
    return "\(minutes)min"
}
