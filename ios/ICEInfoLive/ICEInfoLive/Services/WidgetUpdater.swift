import Foundation
import WidgetKit
import OSLog

actor WidgetUpdater {
    private let logger = Logger(subsystem: "com.nruge.iceinfo", category: "WidgetUpdater")
    private let suiteName = "group.com.nruge.iceinfo"
    private var defaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }

    func update(trainStatus: TrainStatus) {
        guard let defaults else { return }

        defaults.set(trainStatus.trainType + " " + trainStatus.trainNumber, forKey: "widget_trainName")
        defaults.set(trainStatus.speed, forKey: "widget_speed")
        defaults.set(trainStatus.nextStop?.station.name, forKey: "widget_nextStop")
        defaults.set(trainStatus.nextStop?.station.evaNr, forKey: "widget_nextStopEva")
        defaults.set(trainStatus.targetStopEva, forKey: "widget_targetStopEva")
        defaults.set(trainStatus.delayMinutes, forKey: "widget_delay")
        defaults.set(trainStatus.isMockMode, forKey: "widget_isMockMode")

        if let targetEva = trainStatus.targetStopEva,
           let targetStop = trainStatus.stops.first(where: { $0.station.evaNr == targetEva }) {
            defaults.set(targetStop.station.name, forKey: "widget_targetStop")
            let isApproaching = targetStop.distanceFromStart - trainStatus.distanceFromStart < 10000
            defaults.set(isApproaching, forKey: "widget_isApproaching")
        } else {
            defaults.set(nil, forKey: "widget_targetStop")
            defaults.set(false, forKey: "widget_isApproaching")
        }

        WidgetCenter.shared.reloadTimelines(ofKind: "ICEInfoLiveWidget")
        logger.info("Widget state updated")
    }
}
