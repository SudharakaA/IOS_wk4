import SwiftUI

struct LightItUpView: View {
    @EnvironmentObject private var stats: StatsVM
    @EnvironmentObject private var location: LocationService
    @StateObject private var viewModel = LightItUpVM()
    @State private var savedFinalScore: Int?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 14), count: 3)
    private let tileColors: [Color] = [.playHubViolet, .playHubSoftBlue, .playHubCoral]

    var body: some View {
        ZStack {
            PlayHubBackground()

            if let score = savedFinalScore {
                ResultView(mode: .lightItUp, score: score) {
                    savedFinalScore = nil
                    viewModel.start()
                }
            } else {
                VStack(spacing: 20) {
                    HStack(spacing: 12) {
                        ScoreBadge(title: "Score", value: "\(viewModel.score)", systemImage: "sparkles", color: .playHubViolet)
                        ScoreBadge(title: "Round", value: "\(viewModel.round + (viewModel.phase == .ready ? 0 : 1))", systemImage: "circle.hexagongrid.fill", color: .playHubSoftBlue)
                    }

                    FriendlyPanel(color: .playHubViolet) {
                        VStack(spacing: 10) {
                            Image(systemName: statusIcon)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(Color.playHubViolet)
                                .symbolEffect(.pulse, isActive: viewModel.phase == .showing)

                            Text(statusTitle)
                                .font(.title2.bold())
                                .foregroundStyle(Color.playHubInk)

                            Text(statusDetail)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 4)

                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(0..<3, id: \.self) { tile in
                                Button {
                                    viewModel.choose(tile: tile)
                                } label: {
                                    GlowTile(
                                        number: tile + 1,
                                        color: tileColors[tile],
                                        isGlowing: viewModel.highlightedTile == tile
                                    )
                                }
                                .buttonStyle(.plain)
                                .disabled(viewModel.phase != .choosing)
                                .accessibilityLabel("Tile \(tile + 1)")
                            }
                        }

                        Button {
                            viewModel.start()
                        } label: {
                            Label(viewModel.phase == .ready ? "Start Game" : "Start Over", systemImage: viewModel.phase == .ready ? "play.fill" : "arrow.clockwise")
                        }
                        .buttonStyle(PrimaryGameButtonStyle(color: .playHubViolet))
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Light It Up")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: viewModel.finalScore) { _, score in
            guard let score else { return }
            location.requestFreshLocation()
            stats.append(mode: .lightItUp, score: score, coordinate: location.coordinateForSession())
            savedFinalScore = score
        }
    }

    private var statusIcon: String {
        switch viewModel.phase {
        case .ready: return "hand.tap.fill"
        case .showing: return "eye.fill"
        case .choosing: return "hand.point.up.left.fill"
        }
    }

    private var statusTitle: String {
        switch viewModel.phase {
        case .ready: return "Ready to glow?"
        case .showing: return "Watch the glow"
        case .choosing: return "Which tile lit up?"
        }
    }

    private var statusDetail: String {
        switch viewModel.phase {
        case .ready: return "A single tile will flash. Pick it to earn 10 points."
        case .showing: return "Keep your eyes on the three tiles."
        case .choosing: return "Tap the tile you just saw glowing."
        }
    }
}

private struct GlowTile: View {
    let number: Int
    let color: Color
    let isGlowing: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(
                LinearGradient(
                    colors: isGlowing ? [color.opacity(0.98), color.opacity(0.62)] : [color.opacity(0.28), color.opacity(0.16)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .aspectRatio(0.9, contentMode: .fit)
            .overlay {
                Text("\(number)")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(isGlowing ? .white : color)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(isGlowing ? .white.opacity(0.9) : color.opacity(0.35), lineWidth: isGlowing ? 3 : 1)
            }
            .shadow(color: color.opacity(isGlowing ? 0.72 : 0.12), radius: isGlowing ? 22 : 6, y: isGlowing ? 8 : 3)
            .scaleEffect(isGlowing ? 1.04 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.65), value: isGlowing)
    }
}
