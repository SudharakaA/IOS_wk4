import SwiftUI

struct TapFrenzyView: View {
    @EnvironmentObject private var stats: StatsVM
    @EnvironmentObject private var location: LocationService
    @StateObject private var viewModel = TapFrenzyVM()
    @State private var savedFinalScore: Int?

    var body: some View {
        ZStack {
            PlayHubBackground()

            if let score = savedFinalScore {
                ResultView(mode: .tapFrenzy, score: score) {
                    savedFinalScore = nil
                    viewModel.start()
                }
            } else {
                VStack(spacing: 20) {
                    GameHeaderView(
                        mode: .tapFrenzy,
                        subtitle: viewModel.isRunning ? "Keep tapping until the timer hits zero." : "Start the timer, then tap the big button as fast as you can."
                    )

                    HStack {
                        ScoreBadge(title: "Seconds Left", value: "\(viewModel.timeRemaining)", systemImage: "timer", color: .playHubCoral)
                        ScoreBadge(title: "Current Score", value: "\(viewModel.score)", systemImage: "bolt.fill", color: .playHubLeaf)
                    }

                    FriendlyPanel(color: GameMode.tapFrenzy.tint) {
                        VStack(spacing: 18) {
                            Text("\(viewModel.score)")
                                .font(.system(size: 92, weight: .bold, design: .rounded))
                                .foregroundStyle(GameMode.tapFrenzy.accent)
                                .frame(maxWidth: .infinity)

                            Text(viewModel.isRunning ? "Tap, tap, tap!" : "Your next high score starts here.")
                                .font(.headline)
                                .foregroundStyle(.secondary)

                            Button {
                                if viewModel.isRunning {
                                    viewModel.tap()
                                } else {
                                    viewModel.start()
                                }
                            } label: {
                                Label(viewModel.isRunning ? "Tap Now" : "Start Round", systemImage: viewModel.isRunning ? "hand.tap.fill" : "play.fill")
                            }
                            .buttonStyle(PrimaryGameButtonStyle(color: viewModel.isRunning ? GameMode.tapFrenzy.accent : GameMode.tapFrenzy.tint))
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Tap Frenzy")
        .onChange(of: viewModel.finalScore) { _, score in
            guard let score else { return }
            location.requestFreshLocation()
            let coordinate = location.coordinateForSession()
            stats.append(mode: .tapFrenzy, score: score, coordinate: coordinate)
            savedFinalScore = score
        }
    }
}
