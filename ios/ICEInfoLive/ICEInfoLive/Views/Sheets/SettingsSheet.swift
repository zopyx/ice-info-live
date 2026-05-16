import SwiftUI

struct SettingsSheet: View {
    @Environment(\.dbTheme) var theme
    @Environment(\.dismiss) var dismiss
    @Bindable var viewModel: AppViewModel

    var body: some View {
        NavigationStack {
            List {
                Section(String(localized: "settings_appearance")) {
                    Picker(String(localized: "theme"), selection: $viewModel.settings.appTheme) {
                        ForEach(AppTheme.allCases, id: \.self) { theme in
                            Text(theme.displayName).tag(theme)
                        }
                    }
                    .pickerStyle(.segmented)

                    Toggle(String(localized: "reduced_motion"), isOn: $viewModel.settings.reducedMotion)
                }

                Section(String(localized: "settings_behavior")) {
                    Toggle(String(localized: "demo_mode"), isOn: .init(
                        get: { viewModel.settings.isMockMode },
                        set: { _ in viewModel.toggleMockMode() }
                    ))

                    if #available(iOS 16.1, *) {
                        Toggle(String(localized: "live_activity"), isOn: .init(
                            get: { viewModel.settings.isLiveActivityEnabled },
                            set: { _ in viewModel.toggleLiveActivity() }
                        ))
                    }
                }

                Section(String(localized: "settings_privacy")) {
                    Toggle(String(localized: "crash_reporting"), isOn: $viewModel.settings.crashReportingEnabled)
                }

                Section {
                    Button(String(localized: "reset_settings")) {
                        viewModel.settings.targetStopEva = nil
                        viewModel.settings.reducedMotion = UIAccessibility.isReduceMotionEnabled
                        viewModel.settings.appTheme = .system
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle(String(localized: "settings_title"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "done")) {
                        dismiss()
                    }
                }
            }
        }
    }
}
