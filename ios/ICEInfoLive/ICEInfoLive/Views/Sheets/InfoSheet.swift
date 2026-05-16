import SwiftUI

struct InfoSheet: View {
    @Environment(\.dbTheme) var theme
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "train.side.front.car")
                                .font(.system(size: 48))
                                .foregroundColor(theme.primary)
                            Text("ICE Info Live")
                                .font(.title2.bold())
                            Text("Version 4.0.2")
                                .font(.caption)
                                .foregroundColor(theme.textSecondary)
                        }
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }

                Section(String(localized: "info_legal")) {
                    Text(String(localized: "info_disclaimer"))
                        .font(.caption)
                        .foregroundColor(theme.textSecondary)
                }

                Section(String(localized: "info_attribution")) {
                    Text("ICE Portal API — Deutsche Bahn")
                        .font(.caption)
                    Text("v6.db.transport.rest")
                        .font(.caption)
                }

                Section {
                    Button(String(localized: "close")) {
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle(String(localized: "info_title"))
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
