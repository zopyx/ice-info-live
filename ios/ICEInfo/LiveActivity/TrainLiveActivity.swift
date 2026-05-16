import Foundation
import ActivityKit

struct TrainActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        let speed: Int
        let trainType: String
        let trainNumber: String
        let nextStop: String
        let eta: String
        let delayMinutes: Int
        let targetStopName: String?
    }

    let trainType: String
    let trainNumber: String
}

struct TrainLiveActivity {
    static func startActivity(status: TrainStatus) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attributes = TrainActivityAttributes(
            trainType: status.trainType,
            trainNumber: status.trainNumber
        )

        let targetStop = status.stops.first { $0.evaNr == status.targetStopEva && !$0.passed }
        let contentState = TrainActivityAttributes.ContentState(
            speed: status.speed,
            trainType: status.trainType,
            trainNumber: status.trainNumber,
            nextStop: status.nextStop,
            eta: status.eta,
            delayMinutes: status.delayMinutes,
            targetStopName: targetStop?.name
        )

        let content = ActivityContent(
            state: contentState,
            staleDate: Date().addingTimeInterval(10)
        )

        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
            print("Live Activity started: \(activity.id)")
        } catch {
            print("Failed to start Live Activity: \(error)")
        }
    }

    static func updateActivity(status: TrainStatus) {
        let targetStop = status.stops.first { $0.evaNr == status.targetStopEva && !$0.passed }
        let contentState = TrainActivityAttributes.ContentState(
            speed: status.speed,
            trainType: status.trainType,
            trainNumber: status.trainNumber,
            nextStop: status.nextStop,
            eta: status.eta,
            delayMinutes: status.delayMinutes,
            targetStopName: targetStop?.name
        )

        let content = ActivityContent(
            state: contentState,
            staleDate: Date().addingTimeInterval(10)
        )

        Task {
            for activity in Activity<TrainActivityAttributes>.activities {
                await activity.update(content)
            }
        }
    }

    static func stopAllActivities() {
        Task {
            for activity in Activity<TrainActivityAttributes>.activities {
                await activity.end(dismissalPolicy: .immediate)
            }
        }
    }
}
