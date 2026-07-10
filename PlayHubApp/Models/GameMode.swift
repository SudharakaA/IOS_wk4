import Foundation
import SwiftUI

enum GameMode: String, CaseIterable, Codable, Identifiable {
    case tapFrenzy = "Tap Frenzy"
    case lightItUp = "Light It Up"
    case quizRush = "Quiz Rush"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .tapFrenzy: return "hand.tap.fill"
        case .lightItUp: return "lightbulb.max.fill"
        case .quizRush: return "questionmark.bubble.fill"
        }
    }

    var tint: Color {
        switch self {
        case .tapFrenzy: return .mint
        case .lightItUp: return .yellow
        case .quizRush: return .orange
        }
    }

    var accent: Color {
        switch self {
        case .tapFrenzy: return .cyan
        case .lightItUp: return .pink
        case .quizRush: return .purple
        }
    }

    var encouragement: String {
        switch self {
        case .tapFrenzy:
            return "Warm up your fingers and chase a quick high score."
        case .lightItUp:
            return "Focus on the glow, then copy the pattern."
        case .quizRush:
            return "Pick fast, trust your brain, and build momentum."
        }
    }

    var description: String {
        switch self {
        case .tapFrenzy:
            return "Tap as fast as you can before the timer ends."
        case .lightItUp:
            return "Watch the pattern, then repeat it without a miss."
        case .quizRush:
            return "Answer quick trivia questions and build a streak."
        }
    }
}
