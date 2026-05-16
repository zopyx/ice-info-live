import Foundation
import UIKit

@Observable
class SettingsService {
    private let defaults: UserDefaults
    private let suiteName = "group.com.nruge.iceinfo"

    var targetStopEva: String? {
        get { string(for: .targetStopEva) }
        set { set(newValue, for: .targetStopEva) }
    }

    var isMockMode: Bool {
        get { bool(for: .isMockMode, defaultValue: false) }
        set { set(newValue, for: .isMockMode) }
    }

    var demoSpeed: Int {
        get { integer(for: .demoSpeed, defaultValue: 114) }
        set { set(newValue, for: .demoSpeed) }
    }

    var onboardingShown: Bool {
        get { bool(for: .onboardingShown, defaultValue: false) }
        set { set(newValue, for: .onboardingShown) }
    }

    var reducedMotion: Bool {
        get { bool(for: .reducedMotion, defaultValue: UIAccessibility.isReduceMotionEnabled) }
        set { set(newValue, for: .reducedMotion) }
    }

    var appTheme: AppTheme {
        get {
            let raw = string(for: .appTheme) ?? "system"
            return AppTheme(rawValue: raw) ?? .system
        }
        set { set(newValue.rawValue, for: .appTheme) }
    }

    var crashReportingEnabled: Bool {
        get { bool(for: .crashReportingEnabled, defaultValue: false) }
        set { set(newValue, for: .crashReportingEnabled) }
    }

    var crashConsentVersion: Int {
        get { integer(for: .crashConsentVersion, defaultValue: 0) }
        set { set(newValue, for: .crashConsentVersion) }
    }

    var isLiveActivityEnabled: Bool {
        get { bool(for: .isLiveActivityEnabled, defaultValue: false) }
        set { set(newValue, for: .isLiveActivityEnabled) }
    }

    init() {
        self.defaults = UserDefaults(suiteName: suiteName) ?? .standard
    }

    // MARK: - Private

    private enum Key: String {
        case targetStopEva
        case isMockMode
        case demoSpeed
        case onboardingShown
        case reducedMotion
        case appTheme
        case crashReportingEnabled
        case crashConsentVersion
        case isLiveActivityEnabled
    }

    private func string(for key: Key) -> String? {
        defaults.string(forKey: key.rawValue)
    }

    private func bool(for key: Key, defaultValue: Bool) -> Bool {
        if defaults.object(forKey: key.rawValue) == nil {
            return defaultValue
        }
        return defaults.bool(forKey: key.rawValue)
    }

    private func integer(for key: Key, defaultValue: Int) -> Int {
        if defaults.object(forKey: key.rawValue) == nil {
            return defaultValue
        }
        return defaults.integer(forKey: key.rawValue)
    }

    private func set(_ value: Any?, for key: Key) {
        defaults.set(value, forKey: key.rawValue)
    }
}

enum AppTheme: String, CaseIterable, Sendable {
    case light
    case dark
    case system

    var displayName: String {
        switch self {
        case .light: return String(localized: "theme_light")
        case .dark: return String(localized: "theme_dark")
        case .system: return String(localized: "theme_system")
        }
    }
}
