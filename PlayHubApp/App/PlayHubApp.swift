import SwiftUI

@main
struct PlayHubApp: App {
    @StateObject private var stats = StatsVM()
    @StateObject private var location = LocationService()
    @StateObject private var notifications = NotificationService()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(stats)
                .environmentObject(location)
                .environmentObject(notifications)
                .task {
                    location.requestPermission()
                    await notifications.refreshAuthorizationStatus()
                }
        }
    }
}
