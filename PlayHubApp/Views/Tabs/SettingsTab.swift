import SwiftUI

struct SettingsTab: View {
    @EnvironmentObject private var stats: StatsVM
    @EnvironmentObject private var notifications: NotificationService

    @AppStorage("dailyChallengeEnabled") private var dailyChallengeEnabled = false
    @AppStorage("dailyChallengeTime") private var dailyChallengeTimeInterval = Date.defaultChallengeTime.timeIntervalSince1970
    @State private var showResetConfirmation = false

    private var dailyChallengeTime: Binding<Date> {
        Binding {
            Date(timeIntervalSince1970: dailyChallengeTimeInterval)
        } set: { newValue in
            dailyChallengeTimeInterval = newValue.timeIntervalSince1970
            if dailyChallengeEnabled {
                Task { await notifications.scheduleDailyChallenge(at: newValue) }
            }
        }
    }

    var body: some View {
        Form {
            Section {
                FriendlyPanel(color: .playHubSoftBlue) {
                    Label("Daily Challenge", systemImage: "bell.badge.fill")
                        .font(.title3.bold())
                    Text("Choose a reminder time and come back for a quick round every day.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            Section("Daily Challenge") {
                Toggle(isOn: $dailyChallengeEnabled) {
                    Label("Notifications", systemImage: "bell.fill")
                }
                .onChange(of: dailyChallengeEnabled) { _, enabled in
                    if enabled {
                        Task { await notifications.scheduleDailyChallenge(at: dailyChallengeTime.wrappedValue) }
                    } else {
                        notifications.cancelDailyChallenge()
                    }
                }

                DatePicker("Challenge Time", selection: dailyChallengeTime, displayedComponents: .hourAndMinute)

                if dailyChallengeEnabled && !notifications.isAuthorized {
                    Text("Notification permission is needed for daily reminders.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Stats") {
                Button(role: .destructive) {
                    showResetConfirmation = true
                } label: {
                    Label("Reset All Stats", systemImage: "trash.fill")
                }
            }
        }
        .playHubScreen()
        .navigationTitle("Settings")
        .task {
            await notifications.refreshAuthorizationStatus()
        }
        .confirmationDialog("Reset all stats?", isPresented: $showResetConfirmation, titleVisibility: .visible) {
            Button("Reset Stats", role: .destructive) {
                stats.resetAllStats()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This removes every completed game session from this device.")
        }
    }
}

private extension Date {
    static var defaultChallengeTime: Date {
        Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date()) ?? Date()
    }
}
