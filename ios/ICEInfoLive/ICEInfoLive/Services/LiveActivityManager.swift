import Foundation
@preconcurrency import ActivityKit
import OSLog

@available(iOS 16.1, *)
@MainActor
class LiveActivityManager: ObservableObject {
    private let logger = Logger(subsystem: "com.nruge.iceinfo", category: "LiveActivity")
    private var currentActivityID: String?

    func startActivity(trainStatus: TrainStatus, targetStop: TrainStop?) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            logger.warning("Live Activities not enabled")
            return
        }

        endActivity()

        let attributes = ICEInfoWidgetAttributes(trainName: "\(trainStatus.trainType) \(trainStatus.trainNumber)")
        let state = makeContentState(trainStatus: trainStatus, targetStop: targetStop)

        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: state,
                pushType: nil
            )
            currentActivityID = activity.id
            logger.info("Started Live Activity: \(activity.id)")
        } catch {
            logger.error("Failed to start Live Activity: \(error.localizedDescription)")
        }
    }

    func updateActivity(trainStatus: TrainStatus, targetStop: TrainStop?) {
        guard let activityID = currentActivityID else { return }
        let state = makeContentState(trainStatus: trainStatus, targetStop: targetStop)
        Task { @MainActor in
            if let activity = Activity<ICEInfoWidgetAttributes>.activities.first(where: { $0.id == activityID }) {
                await activity.update(state)
            }
        }
    }

    func endActivity() {
        guard let activityID = currentActivityID else { return }
        Task { @MainActor in
            if let activity = Activity<ICEInfoWidgetAttributes>.activities.first(where: { $0.id == activityID }) {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
        currentActivityID = nil
        logger.info("Ended Live Activity")
    }

    private func makeContentState(trainStatus: TrainStatus, targetStop: TrainStop?) -> ActivityContent<ICEInfoWidgetAttributes.ContentState> {
        let target = targetStop ?? trainStatus.nextStop
        let eta = target?.timetable.actualArrival ?? target?.timetable.scheduledArrival
        let progress = trainStatus.totalDistance > 0
            ? Double(trainStatus.distanceFromStart) / Double(trainStatus.totalDistance)
            : 0

        let isApproaching = isApproachingTarget(trainStatus: trainStatus, targetStop: target)

        let state = ICEInfoWidgetAttributes.ContentState(
            speed: trainStatus.speed,
            nextStop: trainStatus.nextStop?.station.name ?? "",
            targetStop: target?.station.name ?? "",
            targetStopEva: target?.station.evaNr ?? "",
            eta: eta?.formatted(date: .omitted, time: .shortened) ?? "--:--",
            delay: trainStatus.delayMinutes,
            progress: progress,
            isApproachingTarget: isApproaching,
            isMockMode: trainStatus.isMockMode
        )

        return ActivityContent(state: state, staleDate: Date().addingTimeInterval(60))
    }

    private func isApproachingTarget(trainStatus: TrainStatus, targetStop: TrainStop?) -> Bool {
        guard let target = targetStop else { return false }
        let remaining = target.distanceFromStart - trainStatus.distanceFromStart
        return remaining > 0 && remaining < 10000
    }
}

// MARK: - Activity Attributes

@available(iOS 16.1, *)
struct ICEInfoWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var speed: Int
        var nextStop: String
        var targetStop: String
        var targetStopEva: String
        var eta: String
        var delay: Int
        var progress: Double
        var isApproachingTarget: Bool
        var isMockMode: Bool
    }

    var trainName: String
}
