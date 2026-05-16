import SwiftUI

struct InfoSheet: View {
    var onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: 8) {
                        Image(systemName: "tram.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(Color(red: 0.925, green: 0, blue: 0.086))
                        Text("ICE Info")
                            .font(.title.weight(.bold))
                        Text("Version 4.0.2")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }

                Section("Datenquellen") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("ICE Portal")
                            .font(.subheadline.weight(.semibold))
                        Text("https://iceportal.de")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("DB Transport API")
                            .font(.subheadline.weight(.semibold))
                        Text("https://v6.db.transport.rest")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Datenschutz") {
                    Text("Diese App sammelt keine personenbezogenen Daten. Alle Daten werden ausschlie\u{00DF}lich von den \u{00F6}ffentlichen ICE-Portal-APIs bezogen und lokal auf dem Ger\u{00E4}t angezeigt.")
                        .font(.caption)
                }

                Section("Rechtliches") {
                    Text("ICE Info ist eine inoffizielle App und steht in keiner Verbindung zur Deutschen Bahn AG. Die App verwendet \u{00F6}ffentlich zug\u{00E4}ngliche Schnittstellen des ICE-Bordportals.")
                        .font(.caption)
                }
            }
            .navigationTitle("\u{00DC}ber")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig", action: onDismiss)
                }
            }
        }
    }
}
