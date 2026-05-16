import SwiftUI

struct DebugSheet: View {
    @State private var tripRaw = ""
    @State private var tripError: String? = nil
    @State private var connectionRaw = ""
    @State private var connectionError: String? = nil
    @State private var evaNr = ""
    @State private var isLoading = true

    var onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            List {
                Section("Ger\u{00E4}t") {
                    LabeledContent("Modell", value: UIDevice.current.model)
                    LabeledContent("iOS", value: UIDevice.current.systemVersion)
                }

                if isLoading {
                    Section {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    }
                } else {
                    Section("Trip API (\(evaNr))") {
                        if let error = tripError {
                            Text(error).foregroundStyle(.red).font(.caption)
                        }
                        Text(tripRaw)
                            .font(.system(.caption, design: .monospaced))
                            .textSelection(.enabled)
                    }

                    Section("Connection API") {
                        if let error = connectionError {
                            Text(error).foregroundStyle(.red).font(.caption)
                        }
                        Text(connectionRaw)
                            .font(.system(.caption, design: .monospaced))
                            .textSelection(.enabled)
                    }
                }
            }
            .navigationTitle("Debug")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig", action: onDismiss)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Kopieren") {
                        let text = """
                        Trip: \(tripRaw)
                        Connection: \(connectionRaw)
                        EVA: \(evaNr)
                        """
                        UIPasteboard.general.string = text
                    }
                }
            }
        }
        .task {
            let data = await TrainRepository.shared.fetchDebugData()
            tripRaw = data.tripRaw
            tripError = data.tripError
            connectionRaw = data.connectionRaw
            connectionError = data.connectionError
            evaNr = data.evaNr
            isLoading = false
        }
    }
}
