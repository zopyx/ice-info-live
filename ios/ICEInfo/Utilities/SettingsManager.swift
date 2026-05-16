import Foundation

enum SettingsKeys {
    static let targetStopEva = "target_stop_eva"
    static let isMockMode = "is_mock_mode"
    static let demoSpeed = "demo_speed"
    static let appTheme = "app_theme"
    static let reducedMotion = "reduced_motion"
    static let language = "language"
    static let crashReportingEnabled = "crash_reporting_enabled"
    static let crashConsentVersion = "crash_consent_version"
    static let onboardingShown = "onboarding_shown"
    static let showDemoSpeed = "show_demo_speed"

    static let appGroupID = "group.com.nruge.iceinfo"
}

@propertyWrapper struct SettingsStorage<T> {
    let key: String
    let defaultValue: T
    let suite: UserDefaults

    init(key: String, defaultValue: T, suite: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.suite = suite
    }

    var wrappedValue: T {
        get { suite.object(forKey: key) as? T ?? defaultValue }
        nonmutating set { suite.set(newValue, forKey: key) }
    }
}

final class SettingsManager: @unchecked Sendable {
    static let shared = SettingsManager()

    private lazy var suite: UserDefaults = {
        UserDefaults(suiteName: SettingsKeys.appGroupID) ?? .standard
    }()

    private init() {}

    @SettingsStorage(key: SettingsKeys.targetStopEva, defaultValue: nil as String?)
    var targetStopEva: String?

    @SettingsStorage(key: SettingsKeys.isMockMode, defaultValue: false)
    var isMockMode: Bool

    @SettingsStorage(key: SettingsKeys.demoSpeed, defaultValue: 114)
    var demoSpeed: Int

    @SettingsStorage(key: SettingsKeys.appTheme, defaultValue: "system")
    var appTheme: String

    @SettingsStorage(key: SettingsKeys.reducedMotion, defaultValue: false)
    var reducedMotion: Bool

    @SettingsStorage(key: SettingsKeys.language, defaultValue: "system")
    var language: String

    @SettingsStorage(key: SettingsKeys.crashReportingEnabled, defaultValue: false)
    var crashReportingEnabled: Bool

    @SettingsStorage(key: SettingsKeys.crashConsentVersion, defaultValue: -1)
    var crashConsentVersion: Int

    @SettingsStorage(key: SettingsKeys.onboardingShown, defaultValue: false)
    var onboardingShown: Bool

    @SettingsStorage(key: SettingsKeys.showDemoSpeed, defaultValue: true)
    var showDemoSpeed: Bool

    var currentTargetStopEva: String? {
        get { targetStopEva }
        set { targetStopEva = newValue }
    }
}
