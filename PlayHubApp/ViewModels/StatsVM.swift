import Foundation
import CoreLocation

@MainActor
final class StatsVM: ObservableObject {
    @Published private(set) var sessions: [GameSession] = []

    private let storageKey = "playhub.sessions"

    init() {
        load()
    }

    var totalGames: Int { sessions.count }
    var totalScore: Int { sessions.reduce(0) { $0 + $1.score } }
    var averageScore: Int { totalGames == 0 ? 0 : totalScore / totalGames }

    var recentSessions: [GameSession] {
        sessions.sorted { $0.timestamp > $1.timestamp }.prefix(8).map { $0 }
    }

    func bestScore(for mode: GameMode) -> Int {
        sessions.filter { $0.mode == mode }.map(\.score).max() ?? 0
    }

    func gamesPlayed(for mode: GameMode) -> Int {
        sessions.filter { $0.mode == mode }.count
    }

    @discardableResult
    func append(mode: GameMode, score: Int, coordinate: CLLocationCoordinate2D) -> GameSession {
        let session = GameSession(
            mode: mode,
            score: score,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
        sessions.insert(session, at: 0)
        save()
        return session
    }

    func resetAllStats() {
        sessions.removeAll()
        save()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        sessions = (try? JSONDecoder().decode([GameSession].self, from: data)) ?? []
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(sessions) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
