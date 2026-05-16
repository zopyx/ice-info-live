import SwiftUI

struct SettingsSheet: View {
    @Binding var appTheme: AppTheme
    @Binding var isMockMode: Bool
    @Binding var showDemoSpeed: Bool
    @Binding var reducedMotion: Bool
    @Binding var crashReportingEnabled: Bool
    var language: String
    var onLanguageChange: (String) -> Void
    var onDebug: () -> Void
    var onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Darstellung") {
                    Picker("Theme", selection: $appTheme) {
                        Text("Hell").tag(AppTheme.light)
                        Text("Dunkel").tag(AppTheme.dark)
                        Text("System").tag(AppTheme.system)
                    }

                    Toggle("Reduzierte Bewegung", isOn: $reducedMotion)
                }

                Section("Demo") {
                    Toggle("Demo-Modus", isOn: $isMockMode)
                    Toggle("Geschwindigkeitsregler", isOn: $showDemoSpeed)
                }

                Section("Sprache") {
                    Picker("Sprache", selection: Binding(
                        get: { language },
                        set: { onLanguageChange($0) }
                    )) {
                        Text("Deutsch").tag("de")
                        Text("English").tag("en")
                        Text("System").tag("system")
                    }
                }

                Section("Crash Reporting") {
                    Toggle("Crash-Berichte", isOn: $crashReportingEnabled)
                }

                Section {
                    Button("Debug-Informationen") {
                        onDebug()
                    }
                }
            }
            .navigationTitle("Einstellungen")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig", action: onDismiss)
                }
            }
        }
    }
}
