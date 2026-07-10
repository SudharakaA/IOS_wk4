import SwiftUI

struct ResultView: View {
    let mode: GameMode
    let score: Int
    let playAgain: () -> Void

    var shareText: String {
        "I just scored \(score) on \(mode.rawValue) - beat that!"
    }

    var body: some View {
        ZStack {
            PlayHubBackground()

            FriendlyPanel(color: mode.tint) {
                VStack(spacing: 24) {
                    Image(systemName: mode.systemImage)
                        .font(.system(size: 60, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 104, height: 104)
                        .background(mode.tint, in: RoundedRectangle(cornerRadius: 8))

                    VStack(spacing: 8) {
                        Text("Nice run!")
                            .font(.title.bold())
                        Text("Final Score")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Text("\(score)")
                            .font(.system(size: 70, weight: .bold, design: .rounded))
                            .foregroundStyle(mode.accent)
                    }

                    ShareLink(item: shareText) {
                        Label("Share Score", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(PrimaryGameButtonStyle(color: mode.accent))

                    Button(action: playAgain) {
                        Label("Play Again", systemImage: "arrow.clockwise")
                    }
                    .buttonStyle(PrimaryGameButtonStyle(color: mode.tint))
                }
            }
            .padding()
        }
    }
}
