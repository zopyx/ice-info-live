import SwiftUI

@main
struct ICEInfoApp: App {
    @AppStorage(SettingsKeys.appTheme) private var appThemeRaw = "system"
    @AppStorage(SettingsKeys.onboardingShown) private var onboardingShown = false
    @AppStorage(SettingsKeys.crashConsentVersion) private var crashConsentVersion = -1
    @State private var showOnboarding = false
    @State private var showCrashConsent = false

    private var appTheme: AppTheme {
        AppTheme(rawValue: appThemeRaw) ?? .system
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(colorScheme)
                .onAppear {
                    if !onboardingShown {
                        showOnboarding = true
                    }
                    let currentVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? Int ?? 0
                    if crashConsentVersion != currentVersion {
                        showCrashConsent = true
                    }
                }
                .sheet(isPresented: $showOnboarding) {
                    OnboardingSheet {
                        onboardingShown = true
                        showOnboarding = false
                    }
                }
                .sheet(isPresented: $showCrashConsent) {
                    CrashConsentSheet(
                        onAccept: {
                            SettingsManager.shared.crashReportingEnabled = true
                            let version = Bundle.main.infoDictionary?["CFBundleVersion"] as? Int ?? 0
                            SettingsManager.shared.crashConsentVersion = version
                            showCrashConsent = false
                        },
                        onDecline: {
                            SettingsManager.shared.crashReportingEnabled = false
                            let version = Bundle.main.infoDictionary?["CFBundleVersion"] as? Int ?? 0
                            SettingsManager.shared.crashConsentVersion = version
                            showCrashConsent = false
                        }
                    )
                    .interactiveDismissDisabled()
                }
        }
    }

    private var colorScheme: ColorScheme? {
        switch appTheme {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}
