import SwiftUI

struct LightItUpView: View {
    @EnvironmentObject private var stats: StatsVM
    @EnvironmentObject private var location: LocationService
    @StateObject private var viewModel = LightItUpVM()
    @State private var savedFinalScore: Int?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)

    var body: some View {
        ZStack {
            LightItUpBackground()

            if let score = savedFinalScore {
                ResultView(mode: .lightItUp, score: score) {
                    savedFinalScore = nil
                    viewModel.start()
                }
            } else {
                ScrollView {
                    VStack(spacing: 22) {
                        titleRow
                        scoreRow
                        gameStatus
                        tileBoard
                        instruction

                        Button {
                            viewModel.start()
                        } label: {
                            Label("Restart game", systemImage: "arrow.clockwise")
                                .font(.subheadline.bold())
                                .foregroundStyle(Color.playHubInk.opacity(0.62))
                        }
                        .padding(.top, 2)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)
                }
                .scrollIndicators(.hidden)
            }
        }
        .navigationTitle("Light It Up")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
        .onAppear { viewModel.startIfNeeded() }
        .onChange(of: viewModel.finalScore) { _, score in
            guard let score else { return }
            location.requestFreshLocation()
            stats.append(mode: .lightItUp, score: score, coordinate: location.coordinateForSession())
            savedFinalScore = score
        }
    }

    private var titleRow: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Light It Up")
                    .font(.system(size: 35, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color.playHubInk)
                Text("Tap the lit tiles before time runs out")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.playHubInk.opacity(0.58))
            }

            Spacer()

            Image(systemName: "lightbulb.fill")
                .font(.system(size: 37, weight: .bold))
                .foregroundStyle(.black)
                .frame(width: 76, height: 76)
                .background(.yellow, in: RoundedRectangle(cornerRadius: 19, style: .continuous))
                .shadow(color: .yellow.opacity(0.3), radius: 15, y: 7)
        }
    }

    private var scoreRow: some View {
        HStack(spacing: 14) {
            ArcadeMetric(title: "SCORE", value: "\(viewModel.score)", color: .yellow, symbol: "sparkles")
            ArcadeMetric(title: "TIME", value: "\(viewModel.timeRemaining)s", color: .cyan, symbol: "timer")
        }
    }

    private var gameStatus: some View {
        HStack {
            HStack(spacing: 7) {
                ForEach(0..<3, id: \.self) { life in
                    Image(systemName: "heart.fill")
                        .font(.title2)
                        .foregroundStyle(life < viewModel.lives ? .red : Color.playHubInk.opacity(0.14))
                        .scaleEffect(life < viewModel.lives ? 1 : 0.82)
                }
            }

            Spacer()

            Text("LEVEL  \(viewModel.level)")
                .font(.title3.bold())
                .tracking(1.1)
            .foregroundStyle(Color(red: 0.72, green: 0.53, blue: 0.0))
        }
        .padding(.horizontal, 3)
    }

    private var tileBoard: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(0..<6, id: \.self) { tile in
                Button {
                    viewModel.tap(tile: tile)
                } label: {
                    ArcadeTile(isLit: viewModel.highlightedTile == tile)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Tile \(tile + 1)\(viewModel.highlightedTile == tile ? ", lit" : "")")
            }
        }
    }

    private var instruction: some View {
        Text("Tap lit tiles only. Wrong taps cost lives.")
            .font(.headline.weight(.semibold))
            .foregroundStyle(Color.playHubInk.opacity(0.66))
            .multilineTextAlignment(.center)
            .padding(.top, 2)
    }
}

private struct ArcadeMetric: View {
    let title: String
    let value: String
    let color: Color
    let symbol: String

    var body: some View {
        VStack(spacing: 9) {
            HStack(spacing: 6) {
                Image(systemName: symbol)
                    .font(.caption.bold())
                Text(title)
                    .font(.caption.bold())
                    .tracking(0.8)
            }
            .foregroundStyle(color)

            Text(value)
                .font(.system(size: 45, weight: .heavy, design: .rounded))
                .foregroundStyle(Color.playHubInk)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 19)
        .background(.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(color.opacity(0.58), lineWidth: 2)
        }
        .shadow(color: color.opacity(0.12), radius: 10, y: 5)
    }
}

private struct ArcadeTile: View {
    let isLit: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: 17, style: .continuous)
            .fill(isLit ? Color.yellow : Color(red: 0.90, green: 0.91, blue: 0.94))
            .aspectRatio(0.94, contentMode: .fit)
            .overlay {
                Image(systemName: isLit ? "sparkles" : "square.grid.3x3.fill")
                    .font(.system(size: isLit ? 39 : 31, weight: .bold))
                    .foregroundStyle(isLit ? .black : Color.playHubInk.opacity(0.26))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 17, style: .continuous)
                .stroke(isLit ? .white.opacity(0.76) : Color.playHubInk.opacity(0.06), lineWidth: isLit ? 2 : 1)
            }
            .shadow(color: isLit ? .yellow.opacity(0.68) : .clear, radius: isLit ? 22 : 0, y: isLit ? 7 : 0)
            .scaleEffect(isLit ? 1.02 : 1)
            .animation(.spring(response: 0.28, dampingFraction: 0.66), value: isLit)
    }
}

private struct LightItUpBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.white, Color(red: 0.97, green: 0.98, blue: 1.0), Color(red: 1.0, green: 0.98, blue: 0.94)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(.cyan.opacity(0.14))
                .frame(width: 230, height: 230)
                .blur(radius: 60)
                .offset(x: 160, y: -350)

            Circle()
                .fill(.purple.opacity(0.10))
                .frame(width: 270, height: 270)
                .blur(radius: 70)
                .offset(x: -150, y: 390)

            Group {
                Circle().fill(.cyan).frame(width: 4, height: 4).offset(x: -150, y: -245)
                Circle().fill(Color.playHubInk.opacity(0.35)).frame(width: 5, height: 5).offset(x: 116, y: -140)
                Circle().fill(.cyan.opacity(0.8)).frame(width: 6, height: 6).offset(x: 128, y: 175)
                Circle().fill(Color.playHubInk.opacity(0.28)).frame(width: 4, height: 4).offset(x: -95, y: 330)
            }
        }
        .ignoresSafeArea()
    }
}
