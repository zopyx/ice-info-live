import Foundation
import Network
import OSLog

@MainActor
@Observable
class WiFiDetectionService {
    private let logger = Logger(subsystem: "com.nruge.iceinfo", category: "WiFiDetection")
    private var monitor: NWPathMonitor?
    private let icePortalURL = URL(string: "https://iceportal.de/api1/rs/status")!

    var isOnTrainNetwork = false
    var isChecking = false

    func startMonitoring() {
        isChecking = true
        Task {
            await checkConnection()
            isChecking = false
        }

        monitor = NWPathMonitor()
        monitor?.pathUpdateHandler = { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                await self.checkConnection()
            }
        }
        monitor?.start(queue: .global(qos: .background))
    }

    func stopMonitoring() {
        monitor?.cancel()
        monitor = nil
    }

    func checkConnection() async {
        do {
            var request = URLRequest(url: icePortalURL)
            request.timeoutInterval = 3
            let (_, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse, (200..<600).contains(http.statusCode) {
                isOnTrainNetwork = true
            } else {
                isOnTrainNetwork = false
            }
        } catch {
            isOnTrainNetwork = false
        }
    }
}
