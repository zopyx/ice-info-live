import SwiftUI

struct ChangelogSheet: View {
    var onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Version 4.0.2")) {
                    Label("Verbesserte POI-Darstellung", systemImage: "mappin")
                    Label("Fehlerbehebungen f\u{00FC}r Verbindungsabbr\u{00FC}che", systemImage: "antenna.radiowaves.left.and.right")
                }
                Section(header: Text("Version 4.0.1")) {
                    Label("Dark Mode Optimierungen", systemImage: "moon.fill")
                    Label("Kompatibilit\u{00E4}t mit neueren ICE-Generationen", systemImage: "tram.fill")
                }
                Section(header: Text("Version 4.0.0")) {
                    Label("Komplett neues Design mit Jetpack Compose", systemImage: "paintpalette.fill")
                    Label("Karte mit OpenStreetMap", systemImage: "map.fill")
                    Label("Points of Interest entlang der Strecke", systemImage: "star.fill")
                    Label("Anschlusszug-Informationen", systemImage: "arrow.triangle.branch")
                    Label("WiFi-Vorhersage mit Zustandswechsel", systemImage: "wifi")
                    Label("Live-Widget f\u{00FC}r den Startbildschirm", systemImage: "square.grid.2x2")
                }
            }
            .navigationTitle("\u{00C4}nderungen")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig", action: onDismiss)
                }
            }
        }
    }
}
