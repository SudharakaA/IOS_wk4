import MapKit
import SwiftUI

struct MapTab: View {
    @EnvironmentObject private var stats: StatsVM
    @EnvironmentObject private var location: LocationService
    @State private var selectedSession: GameSession?
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612),
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        )
    )

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(position: $position, selection: $selectedSession) {
                ForEach(stats.sessions) { session in
                    Marker(
                        "\(session.mode.rawValue) - \(session.score)",
                        systemImage: session.mode.systemImage,
                        coordinate: CLLocationCoordinate2D(latitude: session.latitude, longitude: session.longitude)
                    )
                    .tint(session.mode.tint)
                    .tag(session)
                }
            }
            .mapControls {
                MapCompass()
                MapUserLocationButton()
            }
            .ignoresSafeArea(edges: .bottom)

            if stats.sessions.isEmpty {
                FriendlyPanel(color: .playHubSoftBlue) {
                    Label("No Game Pins Yet", systemImage: "map.fill")
                        .font(.headline)
                    Text("Complete a game and its score will appear here as a colorful map pin.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                    .padding()
            } else if let selectedSession {
                FriendlyPanel(color: selectedSession.mode.tint) {
                    HStack(spacing: 14) {
                        Image(systemName: selectedSession.mode.systemImage)
                            .font(.title2)
                            .foregroundStyle(.white)
                            .frame(width: 46, height: 46)
                            .background(selectedSession.mode.tint, in: RoundedRectangle(cornerRadius: 8))
                        VStack(alignment: .leading, spacing: 4) {
                            Text(selectedSession.mode.rawValue)
                                .font(.headline)
                            Text("Score \(selectedSession.score)")
                                .font(.title3.bold())
                                .foregroundStyle(selectedSession.mode.accent)
                            Text(selectedSession.timestamp, style: .time)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Map")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            location.requestPermission()
            if let first = stats.sessions.first {
                position = .region(
                    MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: first.latitude, longitude: first.longitude),
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                )
            }
        }
    }
}
