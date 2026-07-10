import SwiftUI

struct ScoreBadge: View {
    let title: String
    let value: String
    var systemImage: String = "star.fill"
    var color: Color = .blue

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(.primary)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(color.opacity(0.26), lineWidth: 1)
        }
        .shadow(color: color.opacity(0.1), radius: 10, y: 5)
    }
}

struct PlayHubBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.93, green: 0.96, blue: 1.0),
                Color(red: 0.98, green: 0.93, blue: 1.0),
                Color(red: 0.96, green: 0.98, blue: 1.0)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct FriendlyPanel<Content: View>: View {
    let color: Color
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            content
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.72), lineWidth: 1)
        }
        .shadow(color: color.opacity(0.16), radius: 18, y: 8)
    }
}

struct PrimaryGameButtonStyle: ButtonStyle {
    var color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.vertical, 17)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [color, color.opacity(0.72)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .shadow(color: color.opacity(0.24), radius: 8, y: 4)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct GameHeaderView: View {
    let mode: GameMode
    let subtitle: String

    var body: some View {
        FriendlyPanel(color: mode.tint) {
            HStack(spacing: 16) {
                Image(systemName: mode.systemImage)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 66, height: 66)
                    .background(mode.tint, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                VStack(alignment: .leading, spacing: 6) {
                    Text(mode.rawValue)
                        .font(.title2.bold())
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

extension View {
    func playHubScreen() -> some View {
        background(PlayHubBackground())
            .scrollContentBackground(.hidden)
    }
}

extension Color {
    static let playHubInk = Color(red: 0.13, green: 0.15, blue: 0.22)
    static let playHubSoftBlue = Color(red: 0.26, green: 0.57, blue: 0.98)
    static let playHubCoral = Color(red: 1.0, green: 0.36, blue: 0.34)
    static let playHubLeaf = Color(red: 0.16, green: 0.72, blue: 0.52)
    static let playHubViolet = Color(red: 0.44, green: 0.30, blue: 0.92)
}
