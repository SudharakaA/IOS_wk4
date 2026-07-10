import SwiftUI

struct HomeTab: View {
    @EnvironmentObject private var stats: StatsVM

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                FriendlyPanel(color: .playHubSoftBlue) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ready to play?")
                            .font(.largeTitle.bold())
                            .foregroundStyle(Color.playHubInk)
                        Text("Pick a mode, finish a round, and watch your stats light up.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                HStack {
                    ScoreBadge(title: "Games Played", value: "\(stats.totalGames)", systemImage: "gamecontroller.fill", color: .playHubSoftBlue)
                    ScoreBadge(title: "Total Score", value: "\(stats.totalScore)", systemImage: "sparkles", color: .playHubCoral)
                }

                ForEach(GameMode.allCases) { mode in
                    NavigationLink(value: mode) {
                        FriendlyPanel(color: mode.tint) {
                            HStack(spacing: 16) {
                                Image(systemName: mode.systemImage)
                                    .font(.system(size: 34, weight: .bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 64, height: 64)
                                    .background(mode.tint, in: RoundedRectangle(cornerRadius: 8))

                                VStack(alignment: .leading, spacing: 6) {
                                    Text(mode.rawValue)
                                        .font(.title3.bold())
                                        .foregroundStyle(Color.playHubInk)
                                    Text(mode.encouragement)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(mode.accent)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }

                FriendlyPanel(color: .playHubLeaf) {
                    HStack(spacing: 14) {
                        Image(systemName: "trophy.fill")
                            .font(.title)
                            .foregroundStyle(Color.playHubLeaf)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Best scores")
                                .font(.headline)
                            Text("Tap Stats after a few rounds to compare every mode.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding()
        }
        .playHubScreen()
        .navigationTitle("PlayHub")
        .navigationDestination(for: GameMode.self) { mode in
            switch mode {
            case .tapFrenzy:
                TapFrenzyView()
            case .lightItUp:
                LightItUpView()
            case .quizRush:
                QuizRushView()
            }
        }
    }
}
