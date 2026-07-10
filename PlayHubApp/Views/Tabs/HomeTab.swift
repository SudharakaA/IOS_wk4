import SwiftUI

struct HomeTab: View {
    @EnvironmentObject private var stats: StatsVM

    var body: some View {
        ZStack {
            HomeVisualBackground()

            ScrollView {
                VStack(spacing: 18) {
                    HomeHero(totalGames: stats.totalGames)

                    HStack(spacing: 12) {
                        ScoreBadge(title: "Games played", value: "\(stats.totalGames)", systemImage: "gamecontroller.fill", color: .playHubSoftBlue)
                        ScoreBadge(title: "Total score", value: "\(stats.totalScore)", systemImage: "sparkles", color: .playHubCoral)
                    }

                    HStack {
                        Text("Choose your challenge")
                            .font(.title3.bold())
                            .foregroundStyle(Color.playHubInk)
                        Spacer()
                        Text("3 GAMES")
                            .font(.caption2.bold())
                            .tracking(1.1)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 4)

                    ForEach(GameMode.allCases) { mode in
                        NavigationLink(value: mode) {
                            HomeGameCard(mode: mode, bestScore: stats.bestScore(for: mode))
                        }
                        .buttonStyle(.plain)
                    }

                    HomeProgressCard(totalGames: stats.totalGames)
                }
                .padding(.horizontal)
                .padding(.vertical, 14)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("PlayHub")
        .navigationBarTitleDisplayMode(.large)
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

private struct HomeHero: View {
    let totalGames: Int

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [.playHubViolet, .playHubSoftBlue, Color(red: 0.22, green: 0.75, blue: 0.82)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Circle()
                .fill(.white.opacity(0.14))
                .frame(width: 180, height: 180)
                .offset(x: 220, y: -60)

            Circle()
                .stroke(.white.opacity(0.16), lineWidth: 18)
                .frame(width: 130, height: 130)
                .offset(x: 220, y: 62)

            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 9) {
                    Text(totalGames == 0 ? "Let’s play!" : "Keep the streak alive")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                    Text(totalGames == 0 ? "Pick a challenge and make your first score." : "You’ve completed \(totalGames) game\(totalGames == 1 ? "" : "s"). Choose your next challenge.")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.82))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                VStack(spacing: 10) {
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 38, weight: .bold))
                    Text("PLAY")
                        .font(.caption2.bold())
                        .tracking(1)
                }
                .foregroundStyle(Color.playHubViolet)
                .frame(width: 78, height: 96)
                .background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                .rotationEffect(.degrees(-5))
                .shadow(color: .black.opacity(0.16), radius: 12, y: 7)
            }
            .padding(22)
        }
        .frame(minHeight: 190)
        .shadow(color: Color.playHubViolet.opacity(0.25), radius: 20, y: 10)
    }
}

private struct HomeGameCard: View {
    let mode: GameMode
    let bestScore: Int

    var body: some View {
        ZStack(alignment: .trailing) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.white.opacity(0.82))
                .overlay {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(mode.tint.opacity(0.26), lineWidth: 1)
                }

            Image(systemName: mode.systemImage)
                .font(.system(size: 84, weight: .bold))
                .foregroundStyle(mode.tint.opacity(0.11))
                .offset(x: 18, y: 6)

            HStack(spacing: 14) {
                Image(systemName: mode.systemImage)
                    .font(.system(size: 27, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 60, height: 60)
                    .background(
                        LinearGradient(colors: [mode.tint, mode.accent], startPoint: .topLeading, endPoint: .bottomTrailing),
                        in: RoundedRectangle(cornerRadius: 19, style: .continuous)
                    )
                    .shadow(color: mode.tint.opacity(0.28), radius: 10, y: 5)

                VStack(alignment: .leading, spacing: 5) {
                    Text(mode.rawValue)
                        .font(.headline.bold())
                        .foregroundStyle(Color.playHubInk)
                    Text(mode.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                    Text(bestScore > 0 ? "BEST  \(bestScore)" : "READY TO PLAY")
                        .font(.caption2.bold())
                        .tracking(0.7)
                        .foregroundStyle(mode.accent)
                        .padding(.top, 2)
                }

                Spacer(minLength: 12)

                Image(systemName: "arrow.right")
                    .font(.headline.bold())
                    .foregroundStyle(mode.accent)
                    .frame(width: 32, height: 32)
                    .background(mode.accent.opacity(0.12), in: Circle())
            }
            .padding(16)
        }
        .frame(minHeight: 108)
        .shadow(color: mode.tint.opacity(0.11), radius: 12, y: 6)
    }
}

private struct HomeProgressCard: View {
    let totalGames: Int

    private var progress: Double { min(Double(totalGames) / 10, 1) }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Player progress", systemImage: "trophy.fill")
                    .font(.headline)
                    .foregroundStyle(Color.playHubInk)
                Spacer()
                Text("\(min(totalGames, 10))/10")
                    .font(.subheadline.bold())
                    .foregroundStyle(Color.playHubLeaf)
            }

            ProgressView(value: progress)
                .tint(.playHubLeaf)
                .scaleEffect(x: 1, y: 1.6, anchor: .center)
                .padding(.vertical, 3)

            Text(totalGames >= 10 ? "Amazing — you completed this starter challenge." : "Complete \(max(10 - totalGames, 0)) more games to finish your starter challenge.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .background(.white.opacity(0.76), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.playHubLeaf.opacity(0.22), lineWidth: 1)
        }
        .padding(.top, 2)
    }
}

private struct HomeVisualBackground: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.94, green: 0.96, blue: 1), Color(red: 0.99, green: 0.94, blue: 1), Color(red: 0.93, green: 0.99, blue: 0.98)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color.playHubSoftBlue.opacity(0.30))
                .frame(width: 270, height: 270)
                .blur(radius: 35)
                .offset(x: animate ? 135 : 95, y: animate ? -260 : -220)

            Circle()
                .fill(Color.playHubViolet.opacity(0.23))
                .frame(width: 240, height: 240)
                .blur(radius: 40)
                .offset(x: animate ? -135 : -95, y: animate ? 310 : 350)

            Circle()
                .stroke(.white.opacity(0.40), lineWidth: 1)
                .frame(width: 380, height: 380)
                .offset(x: 140, y: 370)
                .rotationEffect(.degrees(animate ? 14 : -8))
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}
