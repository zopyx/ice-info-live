import Foundation
import Network
import SystemConfiguration.CaptiveNetwork

@Observable
final class NetworkMonitor: @unchecked Sendable {
    var isWIFIonICE = false
    var isChecking = false

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isChecking = false
                if path.status == .satisfied {
                    await self?.checkSSID()
                } else {
                    self?.isWIFIonICE = false
                }
            }
        }
        monitor.start(queue: queue)
    }

    func checkSSID() async {
        guard let interfaces = CNCopySupportedInterfaces() as? [String] else {
            isWIFIonICE = false
            return
        }
        for interface in interfaces {
            guard let info = CNCopyCurrentNetworkInfo(interface as CFString) as? [String: Any],
                  let ssid = info[kCNNetworkInfoKeySSID as String] as? String else {
                continue
            }
            if ssid == "WIFIonICE" {
                isWIFIonICE = true
                return
            }
        }
        isWIFIonICE = false
    }

    deinit {
        monitor.cancel()
    }
}
