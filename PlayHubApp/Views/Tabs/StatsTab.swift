import Charts
import SwiftUI

struct StatsTab: View {
    @EnvironmentObject private var stats: StatsVM

    var body: some View {
        List {
            Section {
                HStack {
                    ScoreBadge(title: "Games", value: "\(stats.totalGames)", systemImage: "gamecontroller.fill", color: .playHubSoftBlue)
                    ScoreBadge(title: "Average", value: "\(stats.averageScore)", systemImage: "divide.circle.fill", color: .playHubCoral)
                }
                HStack {
                    ForEach(GameMode.allCases) { mode in
                        ScoreBadge(title: mode.rawValue, value: "\(stats.bestScore(for: mode))", systemImage: mode.systemImage, color: mode.tint)
                    }
                }
            } header: {
                Text("Totals and Bests")
            }

            Section("Scores by Mode") {
                if stats.sessions.isEmpty {
                    ContentUnavailableView("No Scores Yet", systemImage: "chart.bar", description: Text("Play a game to build your chart."))
                } else {
                    Chart(stats.sessions) { session in
                        BarMark(
                            x: .value("Mode", session.mode.rawValue),
                            y: .value("Score", session.score)
                        )
                        .foregroundStyle(session.mode.tint.gradient)
                        .cornerRadius(6)
                    }
                    .frame(height: 220)
                    .chartLegend(.hidden)
                    .padding(.vertical, 8)
                }
            }

            Section("Recent Games") {
                if stats.recentSessions.isEmpty {
                    ContentUnavailableView("No Recent Games", systemImage: "clock")
                } else {
                    ForEach(stats.recentSessions) { session in
                        HStack {
                            Image(systemName: session.mode.systemImage)
                                .foregroundStyle(.white)
                                .frame(width: 34, height: 34)
                                .background(session.mode.tint, in: RoundedRectangle(cornerRadius: 8))
                            VStack(alignment: .leading) {
                                Text(session.mode.rawValue)
                                    .font(.headline)
                                Text(session.timestamp, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text("\(session.score)")
                                .font(.headline.monospacedDigit())
                                .foregroundStyle(session.mode.accent)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .playHubScreen()
        .navigationTitle("Stats")
    }
}
